--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid         (mappend)
import           Data.Time.Format    (TimeLocale (..))
import           Data.Time.LocalTime (TimeZone (..))
import           Hakyll


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

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
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
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateFieldWith brTimeLocale "date" "%A, %e de %B de %Y" `mappend`
    defaultContext

brTimeLocale :: TimeLocale
brTimeLocale =  TimeLocale {
    wDays  = [ ("domingo",      "dom"), ("segunda-feira", "seg")
             , ("terça-feira",  "ter"), ("quarta-feira" , "qua")
             , ("quinta-feira", "qui"), ("sexta-feira"  , "sex")
             , ("sábado",       "sab")
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
