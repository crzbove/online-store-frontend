<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require_once 'vendor/autoload.php';
require_once 'MailConfig.php';

class Mail
{
    public static function Send($cart)
    {
        $mail = new PHPMailer(true);
        $email = $cart[0]['email'];

        $body = self::GenerateMailBody($cart);
        try {
            $mail->isSMTP();
            $mail->Host = SMTPServer;
            $mail->SMTPAuth = true;
            $mail->Username = Username;
            $mail->Password = Password;
            $mail->SMTPSecure = 'ssl';
            $mail->Port = 465;
            $mail->CharSet = 'utf-8';

            $mail->setFrom(MailFrom, MailFromName);
            $mail->addAddress($email);

            $mail->isHTML(true);
            $mail->Subject = Subject;
            $mail->Body = $body;

            $mail->send();
        } catch (Exception $e) {
        }
    }

    private static function GenerateRows($cart)
    {
        $rows = "";
        for ($i = 0; $i < sizeof($cart); $i++) {
            $rows .= <<<HTML
                <tr>
                    <td><img src="{$cart[$i]['imageuri']}" height="64px"></td>
                    <td>{$cart[$i]['name']}</td>
                    <td>{$cart[$i]['count']}</td>
                    <td>{$cart[$i]['cost']}</td>
                    <td>{$cart[$i]['total']}</td>
                <tr>
HTML;


        }
        return $rows;
    }

    private static function GenerateMailBody($cart)
    {
        $totalSum = $cart[0]['TOTALSUM'];
        $rows = self::GenerateRows($cart);

        $html = <<<HTML
    <html>
        <table border="1">
             
        <thead>
        <tr>
            <th>Изображение</th>
            <th>Название</th>
            <th>Количество</th>
            <th>Цена за 1 шт.</th>
            <th>Всего</th>
        </tr>
        </thead>
        
        <tbody>
            $rows
        </tbody>
        
        </table>
        Всего к оплате: $totalSum
    </html>
        
 HTML;
        return $html;
    }
}