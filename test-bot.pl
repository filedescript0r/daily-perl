#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

# Ваш токен
my $token = '7728524419:AAGteRdyPf2sQ7pK3z0LOKHpPwfDbOhAZMs';
# URL для API Telegram
my $url = "https://api.telegram.org/bot$token/";
# Настройка вебхука
my $server_ip = '171.22.124.111';
my $port = 80; # или 443 для HTTPS

# Создание сокета
my $socket = IO::Socket::INET->new(
    LocalAddr => $server_ip,
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => SOMAXCONN,
    Reuse     => 1
) or die "Не удалось создать сокет: $!";

print "Сервер запущен на $server_ip:$port\n";

while (my $client = $socket->accept()) {
    my $request = '';
    $client->recv($request, 1024);
    
    if ($request =~ m{POST /webhook}g) {
        # Обработка входящего сообщения
        my ($update) = $request =~ /Content-Length: (\d+)/;
        my $json = '';
        $client->recv($json, $update);
        
        # Здесь вы можете обработать $json и отправить ответ
        print "Получено сообщение: $json\n";
        
        # Пример отправки сообщения обратно в Telegram
        my $chat_id = 'YOUR_CHAT_ID'; # Замените на ваш chat_id
        my $message = "Hello from Perl bot!";
        my $send_message_url = "${url}sendMessage?chat_id=$chat_id&text=$message";
        
        # Отправка сообщения
        my $response = `curl -s "$send_message_url"`;
        print "Ответ от Telegram: $response\n";
    }
    
    close($client);
}

close($socket);
