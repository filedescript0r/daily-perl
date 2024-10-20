#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Status;
use LWP::UserAgent;
use JSON;

my $token = '7728524419:AAGteRdyPf2sQ7pK3z0LOKHpPwfDbOhAZMs';
my $url = "https://api.telegram.org/bot$token";

# Создаем HTTP-сервер
my $d = HTTP::Daemon->new(
    LocalAddr => '0.0.0.0',  # Слушаем на всех интерфейсах
    LocalPort => 8080,        # Порт, на котором будет работать сервер
    Reuse => 1,
) or die "Failed to create HTTP daemon: $!";

print "Server is running at: <URL>\n";

# Устанавливаем вебхук
set_webhook();

while (my $c = $d->accept()) {
    while (my $r = $c->get_request()) {
        if ($r->method eq 'POST' && $r->uri->path eq '/webhook') {
            my $update = decode_json($r->content);
            handle_update($update);
            $c->send_response(HTTP::Response->new(RC_OK));
        } else {
            $c->send_error(RC_NOT_FOUND);
        }
    }
    $c->close;
    undef($c);
}

sub set_webhook {
    my $webhook_url = 'http://yourdomain.com:8080/webhook'; # Замените на ваш URL
    my $ua = LWP::UserAgent->new;
    $ua->get("$url/setWebhook?url=$webhook_url");
}

sub handle_update {
    my ($update) = @_;
    if (my $message = $update->{message}) {
        my $chat_id = $message->{chat}->{id};
        my $text = $message->{text};

        if ($text eq '/start') {
            send_message($chat_id, 'Привет! Я ваш бот.');
        }
    }
}

sub send_message {
    my ($chat_id, $text) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->post("$url/sendMessage", {
        chat_id => $chat_id,
        text    => $text,
    });
}
