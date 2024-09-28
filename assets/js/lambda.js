const handler = event => {
  const email = event["Records"][0]["ses"]["mail"]
  const recipientEmail = email["source"]
  const message = {
    messageId: email["messageId"],
    receivedAt: email["timestamp"],
    recipientEmail
  }

  console.log({ dynamoPutRecipients: { emailAddress: recipientEmail } })
  console.log({ dynamoPutMessages: message })
}

const lambdaEvent = 
{
  "Records": [{
    "eventSource": "aws:ses",
    "eventVersion": "1.0",
    "ses": {
      "mail": {
        "timestamp": "2024-09-27T19:15:21.083Z",
        "source": "dgrosenblatt@gmail.com",
        "messageId": "r1fq0gf2a1diuumbmlim2ccks81qq5hlj2j382g1", // key in S3 bucket, weekly-email-dot-wtf
        "destination": ["hello@weeklyemail.wtf"],
        "headersTruncated": false,
        "headers": [{
          "name": "Return-Path",
          "value": "<dgrosenblatt@gmail.com>"
        }, {
          "name": "Received",
          "value": "from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42]) by inbound-smtp.us-east-1.amazonaws.com with SMTP id r1fq0gf2a1diuumbmlim2ccks81qq5hlj2j382g1 for hello@weeklyemail.wtf; Fri, 27 Sep 2024 19:15:21 +0000 (UTC)"
        }, {
          "name": "X-SES-Spam-Verdict",
          "value": "PASS"
        }, {
          "name": "X-SES-Virus-Verdict",
          "value": "PASS"
        }, {
          "name": "Received-SPF",
          "value": "pass (spfCheck: domain of _spf.google.com designates 209.85.218.42 as permitted sender) client-ip=209.85.218.42; envelope-from=dgrosenblatt@gmail.com; helo=mail-ej1-f42.google.com;"
        }, {
          "name": "Authentication-Results",
          "value": "amazonses.com; spf=pass (spfCheck: domain of _spf.google.com designates 209.85.218.42 as permitted sender) client-ip=209.85.218.42; envelope-from=dgrosenblatt@gmail.com; helo=mail-ej1-f42.google.com; dkim=pass header.i=@gmail.com; dmarc=pass header.from=gmail.com;"
        }, {
          "name": "X-SES-RECEIPT",
          "value": "AEFBQUFBQUFBQUFIUWtkSjhLS2I4Wm44ejFkbFMva2h3Wlh4NG56V003eU9SNlR1UXlBdUJMT0FJRWwyN0R1UHBHT1lZck9XQ3ZVWFhBV0JrNG40MFRNYkFYd2V6eFVJSXlTTG1ZNFhMcnFQbXoxcDR3d0pEMFpZc3NXY2lCY1NKSzlzbHBndG1uY0ZwcnpVZGJiYWpibGJPTGtsR05TYjc3aWp2bjhtcTBESCtoR0hzQS9zVkk5R3hTSkJaSGk1L01WNUVWbGdMbW9YRlRqREFVSlBIcGJ1TTFtY282NVBGUFNFVkVMNHdId2F5dStVK3NZcDV4cHRhQU1rd3VIQU4xY2Q5SFFXYUpwK21qOUVjRTM4UHdtaW5oUlNTN1F5REZyZGM0SGY2S2QwUkl3Zy9mWXptOWc9PQ=="
        }, {
          "name": "X-SES-DKIM-SIGNATURE",
          "value": "a=rsa-sha256; q=dns/txt; b=MDU0ghmVw22SCmPKyX31ls4x1XQ6kdsjxZLc9+iWPSdgVQ5gJylXBK9IBWm19rmVzHPjPux70iHQ8I687LAHE3UTdWwWKt2rh89y+c78BEN+l2YPOFMdAn7XaRAJfIdR5JvPrlpsSnYD8Y8emnLzZsNaMPU7e/7lPpeKqPeDWaM=; c=relaxed/simple; s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1727464521; v=1; bh=iYz3lodVgN5WkRIFRbbA0lDWfu1gtt/aKbhmQLi22Tg=; h=From:To:Cc:Bcc:Subject:Date:Message-ID:MIME-Version:Content-Type:X-SES-RECEIPT;"
        }, {
          "name": "Received",
          "value": "by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-a93b2070e0cso282870666b.3 for <hello@weeklyemail.wtf>; Fri, 27 Sep 2024 12:15:20 -0700 (PDT)"
        }, {
          "name": "DKIM-Signature",
          "value": "v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20230601; t=1727464519; x=1728069319; darn=weeklyemail.wtf; h=to:subject:message-id:date:from:mime-version:from:to:cc:subject:date:message-id:reply-to; bh=iYz3lodVgN5WkRIFRbbA0lDWfu1gtt/aKbhmQLi22Tg=; b=VY57N7GDdhAwd4mHnXBQSlGaN3eEpNhvHXT1Vas2ujQvTxIn9Fox/fXnm6E+0UdTSsSJ9XFEceXGAWvTL9r6WdbZmRgXnjv5jTBnm8JoahEVJPUojdGFqwfTE5SQWdmXLE77VI0BY8UgqSbnNGAvDzuyCkbVp3n70IrZGPukldCp+75MBRssvKr28Z6zJLZWtCkb6HAR/X5d5E6+jJ1+N5rJXlgieuXYG/WDg+wOfpBt3bunjAO/ndkLt7jrldspQbP6l6IevpIbRZIOueKZsbH0JOsHyQHV1w5VYUnzK989An2uZbdl73cMBCqCrKXW/0YD4SC7FGe6IalRq7LN6w=="
        }, {
          "name": "X-Google-DKIM-Signature",
          "value": "v=1; a=rsa-sha256; c=relaxed/relaxed; d=1e100.net; s=20230601; t=1727464519; x=1728069319; h=to:subject:message-id:date:from:mime-version:x-gm-message-state :from:to:cc:subject:date:message-id:reply-to; bh=iYz3lodVgN5WkRIFRbbA0lDWfu1gtt/aKbhmQLi22Tg=; b=ZQetYsbVelWtP2WkZz8U+LBKdgqobadaXjI74VVek6mvlJgJk60Plao4Rh6sMHDsUf b1e+p+zro74ouc1o4S/zfz5qZJIXrO9Rb4xbu1zYjejmuiVBD+0yblwyYA007pHLsQ20 R3h67Qh6hl52ofxy/NaEoM2wDVA4jSw7wfTrshcpFfZXUeV5ROs8cT0CtnPn5yGFNhwL GaTTiDJ5mbqNzIyCFhTwQp/Wb0MntAa8rC5CXnn4XHMUsXOxbEIdJJ1cnVKw7GOUalNP UdtopLMeq+vJTUNjLUCF3tCtOF2FUBMMFynMdqvFu/Wsm94oGmAx59U8I7JzZO7EHWqQ fxpA=="
        }, {
          "name": "X-Gm-Message-State",
          "value": "AOJu0YwQVfpW9vgVEtdtYz/+xYisnKnW6rtY5yhDcFtikCuCFdF+Fo+o 5VV7juY6qC8GAUgkhaIcWcORk1YQ3Mze1E9oAYg8hPajml/ebWArIWSvtDDWriB46UQz5HBXrHT /+MWisKIfmc2rBkXw9ovvKg6IiyGYxQ=="
        }, {
          "name": "X-Google-Smtp-Source",
          "value": "AGHT+IEEJUfIA/AYQJBWsyyfahnY7ksNk+n0HddS1Yk8fy+M9dwdu+mBxtqY3EG4ZNbVWIGpIYzXdSEMp8Ge6wF4780="
        }, {
          "name": "X-Received",
          "value": "by 2002:a17:907:3e99:b0:a86:ac91:a571 with SMTP id a640c23a62f3a-a93c4c256famr375491966b.56.1727464519362; Fri, 27 Sep 2024 12:15:19 -0700 (PDT)"
        }, {
          "name": "MIME-Version",
          "value": "1.0"
        }, {
          "name": "From",
          "value": "Daniel Rosenblatt <dgrosenblatt@gmail.com>"
        }, {
          "name": "Date",
          "value": "Fri, 27 Sep 2024 15:15:08 -0400"
        }, {
          "name": "Message-ID",
          "value": "<CAG5G021x_=Ph4srM2oQiGCkTqN=Qx1f7GJnbWOy3C+sTGGUhKw@mail.gmail.com>"
        }, {
          "name": "Subject",
          "value": "this is a test"
        }, {
          "name": "To",
          "value": "hello@weeklyemail.wtf"
        }, {
          "name": "Content-Type",
          "value": "multipart/alternative; boundary=\\"
        }],
        "commonHeaders": {
          "returnPath": "dgrosenblatt@gmail.com",
          "from": ["Daniel Rosenblatt <dgrosenblatt@gmail.com>"],
          "date": "Fri, 27 Sep 2024 15:15:08 -0400",
          "to": ["hello@weeklyemail.wtf"],
          "messageId": "<CAG5G021x_=Ph4srM2oQiGCkTqN=Qx1f7GJnbWOy3C+sTGGUhKw@mail.gmail.com>",
          "subject": "this is a test"
        }
      },
      "receipt": {
        "timestamp": "2024-09-27T19:15:21.083Z",
        "processingTimeMillis": 818,
        "recipients": ["hello@weeklyemail.wtf"],
        "spamVerdict": {
          "status": "PASS"
        },
        "virusVerdict": {
          "status": "PASS"
        },
        "spfVerdict": {
          "status": "PASS"
        },
        "dkimVerdict": {
          "status": "PASS"
        },
        "dmarcVerdict": {
          "status": "PASS"
        },
        "action": {
          "type": "Lambda",
          "functionArn": "arn:aws:lambda:us-east-1:284615196714:function:weekly-email",
          "invocationType": "Event"
        }
      }
    }
  }]
}

handler(lambdaEvent)
