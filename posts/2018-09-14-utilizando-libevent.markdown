---
title: Utilizando libevent
description: TCP/IP com eventos?
tags: tcp/ip, c/c++, programação
---

Normalmente, drivers para banco de dados sofrem um problema recorrente:
Timeouts por algum tipo de ativo de rede. Não é incomum ver uma query
rodando a minutos sem qualquer utilização da rede. Neste cenário, um
ativo de rede como um firewall pode cortar a conexão numa forma de
proteger o servidor, por exemplo.

Logo, quando se projeta um driver para utilização na rede, pode ser
necessário fazer uma limpeza por conexões mortas por timeouts em certos
momentos da execução da aplicação.

No nível de pacote, a aplicação recebera um pacote RST vindo do firewall.
Caso for o read do socket, a aplicação receberá uma mesagem vazia. Caso
for o write, a aplicação receberá algum tipo de erro, como um Broken Pipe.
No entanto, especificamente um driver cliente para um serviço, várias
conexões estarão ociosas e, reativamente, só perceberemos as ruins no
momento do write, momento em que o cliente fará uma requisição.

Vamos supor agora numa configuração dos astros, esse write nunca aconteça.
Por uma consequência lógica, as conexões se acumularão até lotar todos
os recursos de rede disponíveis, o chamado Connection Leak.

A libevent permite que você programe o socket para ser notificado dos
eventos, por exemplo um READ, antes do WRITE.

Eu criei um exemplo simples que para mostrar o tempo do timeout para
qualquer ip e porta, apenas para degustar a biblioteca. E nesse artigo 
gostaria de compartilhar. Ainda, não tenho disponível uma área de
comentário, peço desculpas pelo inconveniente.

```c
int sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
connect(sockfd, p->ai_addr, p->ai_addrlen);
fcntl(sockfd, F_SETFL, fcntl(sockfd, F_GETFL) | O_NONBLOCK);
```

Basicamente, deve-se criar o socket e deixá-lo em modo non-block. Isto é,
quando fizer um read, meu código não esperará pelo retorno, em um momento
posterior terei que fazer a leitura. Estou resumindo o assunto por sua
profundidade, mas eu espero continuar a pesquisa por conta do interesse.

Em um segundo momento, iniciaremos a libenvent com o comando

```c
event_init();
```

Criaremos um evento base e registraremos um evento para a leitura. Nesse
registro, definiremos a função a ser executada ao acontecer o evento

```c
struct event_base *base = event_base_new();
struct event *ev_read;
ev_read = event_new(base, client_sock, EV_READ, on_read, &end_clock);
event_add(ev_read, 0);
```

Acionaremos o loop da libevent

```c
event_base_dispatch(base);
```

Segue a definição da função on_read, que será acionada no momento do evento

```c
void on_read(int sock, short ev, void *arg)
{
  assert(ev == EV_READ);

  char one_byte;

  if (recv(sock, &one_byte, 1, MSG_PEEK | MSG_DONTWAIT) == 0)
    {
	  // alguma logica
      event_loopbreak();
    }
}
```

Importante, o recv está com a flag MSG_PEEK e MSG_DONTWAIT. MSG_PEEK é para
consumir um caracter sem retirar do buffer TCP/IP e o MSG_DONTWAIT é para
não esperar. Por fim, o event_loopbreak informa para sair do loop da libevent.

O código de exemplo estará no meu gist do github.

Por fim, achei a utilização da libevent bem simples. Agora, vou ver mais
exemplos onde pode ser aplicado.
