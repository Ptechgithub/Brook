Brook

A cross-platform programmable network tool.

# اسکریپت نصب brook
با امکانات :

تغییر پورت ، پسورد ، path و نصب Custom

پس از نصب با گزينه 1 ، که نیازمند دامین می‌باشد لینک `brook` و همچنین ادرس `server` و `password` برای کلاینت نمایش داده میشود. که میتوانید در کلاینت های ذکر شده استفاده کنید.

پس از انتخاب روش 1 پروکسی دامین شما باید خاموش باشد تا فرآیند گرفتن گواهی ها با مشکل مواجه نشود و خطا دریافت نکنید. پس از نصب کامل میتوانید پروکسی را روشن کنید با این کار اگر `IP` شما فیلتر هم باشد بدون مشکل کار میکند . فقط توجه کنید که دامین باید سالم باشد.
و نکته ی دیگر  اینکه اگر از `Cloudflare ` استفاده میکنید در این روش از یکی از پورت های `443` `2087` `2096` `8443` `2053` `2083` استفاده کنید.

نکته: پورت `80` آزاد باشد چون نیاز است که برای دامین شما گواهی گرفته شود. پس از نصب پورت آزاد است.

دسترسی به دامین `IR` به طور خودکار پس از نصب ، با روش اول `block` میشود .(جهت جلوگیری از شناسایی و فیلتر شدن دامنه شما)

در روش Custom شما فقط دستور مورد نیاز خودتان را وارد میکنید و سرویس آن فعال خواهد شد .
با این کار میتوانید از روش بدون دامین و یا پروتکل quic و ... استفاده کنید. 

در روش Custom و روش 1 ، پس از ریستارت شدن مجدد سرویس فعال میشود و دسترسی شما قطع نخواهد شد.


## Install
```
bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/Brook/main/install.sh)
```
![25](https://raw.githubusercontent.com/Ptechgithub/configs/main/media/25.jpg)


## GUI Client

| iOS | Android      | Mac    |Windows      |Linux        |OpenWrt      |
| --- | --- | --- | --- | --- | --- |
| [![](https://brook.app/images/appstore.png)](https://apps.apple.com/us/app/brook-network-tool/id1216002642) | [![](https://brook.app/images/android.png)](https://github.com/txthinking/brook/releases/latest/download/Brook.apk) | [![](https://brook.app/images/mac.png)](https://apps.apple.com/us/app/brook-network-tool/id1216002642) | [![Windows](https://brook.app/images/windows.png)](https://github.com/txthinking/brook/releases/latest/download/Brook.msix) | [![](https://brook.app/images/linux.png)](https://github.com/txthinking/brook/releases/latest/download/Brook.bin) | [![OpenWrt](https://brook.app/images/openwrt.png)](https://github.com/txthinking/brook/releases) |
| / | / | [App Mode](https://www.txthinking.com/talks/articles/macos-app-mode-en.article) | [How](https://www.txthinking.com/talks/articles/msix-brook-en.article) | [How](https://www.txthinking.com/talks/articles/linux-app-brook-en.article) | [How](https://www.txthinking.com/talks/articles/brook-openwrt-en.article) |

[پلاگین Nekobox](https://github.com/MatsuriDayo/plugins/releases/tag/Brook-v20220707-1)


[Brook Project](https://github.com/txthinking/brook)

جهت حمایت میتوانید بر روی دکمه ی 🌟 Star  در بالای صفحه کلیک کنید.