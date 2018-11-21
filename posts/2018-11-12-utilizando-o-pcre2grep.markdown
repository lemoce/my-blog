---
title: 'Utilizando o pcre2grep'
description: 'Será que volto para o combo grep/sed?'
tags: computacao, unix, shell
---

Quando eu estudei programação da Windows API com C, eu
fiz um grep utilizando a biblioteca [pcre2](https://www.pcre.org/).
Nesse momento, eu somente utilizei com a finalidade de
estudar a api do Windows, mas eu percebi que tinha algumas
vantagens, por exemplo, usar o perl regex. O perl regex
é muito mais fexível que o POSIX regex, permite casamento
menos verborrágico. Java e Python utilizam esse padrão
para criar os patterns de regex. Um ponto negativo é o
fato do seu sistema não ter nativamente a api para a
utilização, dessa forma é necessário compilar do fonte.

De vez em quando, eu preciso fazer análises de logs.
Recorrentemente, eu volto aos programas porque não é uma
tarefa que faço rotineiramente. Assim, eu tenho que
lembrar das ferramentas que fiz para poder jogar os dados
no banco de dados. Mas, agora que passou muito tempo
a minha idéia original foi toda desfigurada, eu tenho que
me reinventar para entender a nova situação de hoje.

Voltando ao pcre2grep, vou dar um exemplo:

```shell
pcre2grep --output='<pcre_regex_replace>' -e "<pcre_regex>"
```

Veja como é simples. Agora, é só usar a [perlre](http://perldoc.perl.org/perlre.html).
Alguns exemplos:

- /d: casa com decimains
- /w: casa com alfanuméricos
- /s: casa com espaços
- ^: casa com começo de linha
- $: casa com fim de linha
- (<pattern>): agrupa para referencia posterior
- $1: referencia do grupo 
- [<conjunto_de_caracteres>]: conjunto de caracteres
- .: qualquer caracter

e por aí vai. No geral, é um grep muito mais poderoso com
sed embutido.
