#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use LWP::UserAgent;
use JSON;

my $token = '7728524---:AAGteRdyPf2sQ7pK3z0LOKHpPwfDbOhAZMs';
my $url = "https://api.telegram.org/bot$token";

# Установите вебхук
sub set_webhook {
    my $webhook_url = 'vm3221814.stark-industries.solutions/webhook'; # Замените на ваш URL
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get("$url/setWebhook?url=$webhook_url");
    return $response->decoded_content;
}

# Обработка обновлений
post '/webhook' => sub {
    my $c = shift;
    my $update = $c->req->json;

    if (my $message = $update->{message}) {
        my $chat_id = $message->{chat}->{id};
        my $text = $message->{text};

        if ($text eq '/start') {
            send_message($chat_id, 'Привет! Я ваш бот.');
        }
    }

    return $c->render(json => { status => 'ok' });
};

# Функция отправки сообщения
sub send_message {
    my ($chat_id, $text) = @_;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->post("$url/sendMessage", {
        chat_id => $chat_id,
        text    => $text,
    });
    return $response->decoded_content;
}

# Установите вебхук при запуске
set_webhook();

app->start;
