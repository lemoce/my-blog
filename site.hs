--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid         (mappend)
import           Data.Time.Format    (TimeLocale (..))
import           Data.Time.LocalTime (TimeZone (..))
import           Hakyll


--------------------------------------------------------------------------------
myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "Lemoce Desire: contemplating a new world"
    , feedDescription = "Thoughts about new ideas and concepts (in Portuguese, English and Japanese)"
    , feedAuthorName  = "Leandro Cerencio"
    , feedAuthorEmail = "cerencio@yahoo.com.br"
    , feedRoot        = "https://boteco.mat.br"
    }


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")
    tagsRules tags $ \tag pattrn -> do
        let title = "Posts tagged \"" ++ tag ++ "\""
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattrn
            let ctx = constField "title" title
                      `mappend` listField "posts" postCtx (return posts)
                      `mappend` defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 5) .recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend`
                              constField "description" "This is post description"
            posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
            renderAtom myFeedConfiguration feedCtx posts

    create ["stats.php"] $ do
        route idRoute
        compile copyFileCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateFieldWith brTimeLocale "date" "%A, %e de %B de %Y" `mappend`
    defaultContext

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx

brTimeLocale :: TimeLocale
brTimeLocale =  TimeLocale {
    wDays  = [ ("Domingo",      "dom"), ("Segunda-feira", "seg")
             , ("Terça-feira",  "ter"), ("Quarta-feira" , "qua")
             , ("Quinta-feira", "qui"), ("Sexta-feira"  , "sex")
             , ("Sábado",       "sab")
             ],

    months = [ ("janeiro",  "jan"), ("fevereiro", "fev")
             , ("março",    "mar"), ("abril",     "abr")
             , ("maio",     "mai"), ("junho",     "jun")
             , ("julho",    "jul"), ("agosto",    "ago")
             , ("setembro", "sep"), ("outubro",   "out")
             , ("novembro", "nov"), ("dezembro",  "dez")
             ],
    amPm = (" antes meio-dia", " após meio-dia"),
    dateTimeFmt = "%a %e %b %Y, %H:%M:%S %Z",
    dateFmt   = "%d/%m/%Y",
    timeFmt   = "%H:%M:%S",
    time12Fmt = "%I:%M:%S %p",
    knownTimeZones = [ TimeZone (-2 * 60) False "FNT"
                     , TimeZone (-3 * 60) False "BRT"
                     , TimeZone (-2 * 60) True  "BRST"
                     , TimeZone (-4 * 60) False "AMT"
                     , TimeZone (-3 * 60) True  "AMST"
                     , TimeZone (-5 * 60) False "ACT"
                     ]
}
