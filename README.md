# funkypenguin18_infra

# ДЗ №17 (monitoring-1)

Создадал правила для фаервола (Prometheus + Puma)

```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```

Пересоздал докер-хост (старый был из домашки для докера, пришлось убивать в докер-машин)

Запустил прометея, посмотрел на него:
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```

Поменял конфигурацию (в monitoring/prometheus создайте файл prometheus.yml)

Собрал образы прометеуса и сервисов, написал мейкфайл.

# ДЗ №16 (gitlab-ci-1)

Разворачивания инстанса в гугл клауд автоматизировано при помощи терраформ,
настройка необходимого программного обеспечения осуществленна при помощи ансибл-скрипта

Создана группа homework и проектт example,
Запущен и зарегестрирован раннер в докере

Статус проверен через CI/CD pipeline,
Приложение Reddit добавлено в наш gitlab репозиторий
Добавили тесты в пайплайн, с добавлением библиотеки для тестированя в гемфайл

Изменены пайплайны для выкатки в дев, затем описаны окружения стейджинг и продакшен

В пайплайн добавлена директива, не позволяющая деплоить в окружения stage и prod без тега git

```
only:
   - /^\d+\.\d+\.\d+/
```

Проверяем с тегом
```
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```
Динамические окружения Добавляем job, который определяет динамическое окружение для всех веток в репозитории, кроме ветки master
```
branch review:
 stage: review
 script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
 environment:
 name: branch/$CI_COMMIT_REF_NAME
 url: http://$CI_ENVIRONMENT_SLUG.example.com
 only:
 - branches
 except:
 - master
```

# ДЗ №15 (docker-4)

Описываем инфраструктуру в файле docker-compose.yml
Останавливаем контейнеры и задаем переменную окружения
export USERNAME=funkypenguin18

Имя проекта берется из текущей папки src, где находится файл docker-compose.
Изменить можно с помощью переменной окружения

COMPOSE_PROJECT_NAME=dockermicroservices

Параметризуем с помощью переменных окружений публикуемый наружу порт ui, верcии сервисов ui, post, comment Параметры внесем в файл .env, который docker-compose подхватит при развертывании. Файл .env внесли в .gitignore. Проверили доступность приложения.

# ДЗ №14 (docker-3)

Создали три контейнера с микросервисами post-py, comment, ui

Были исправлены докерфайлы для корректной сборки образов.
Создана докер бридж сеть.
Запустили докер контейнеры с добавлением сетевых алиасов.
Проверена корректность работы приложени в докер-машин.

# ДЗ №13 (docker-2)

Создан образ, проверена работоспособность, затем образ загружен в докерхаб
https://cloud.docker.com/u/funkypenguin18/repository/docker/funkypenguin18/otus-reddit

# ДЗ №12 (docker-1)

выполнил обзорную д/з по докеру

# ДЗ №11 (ansible-4)

* Установлен Vagrant + VirtualBox для локальной разработки ролей

* Доработаны роли app и db (сделали провижининг)

* Настроено тестирование ролей с помощью Molecule и Testinfra, в т.ч.
написан тест к роли db для проверки использования БД на порту 27017

* В шаблонах Packer теперь Ansible роли вместо плейбуков

Задание со * №1
В конфигурацию vagrant добавлено проксирование приложения с помощью nginx,
проверно корректность отображения на 80-м порту.


# ДЗ №10 (ansible-3)

* Cозданные ранее плейбуки перенесены в отдельные роли

* Описаны два окружения - prod и stage

* Использована коммьюнити роль nginx (обращение к 80-му порту)
для чего добавлено правило для этого порта в терраформ

* Использована технология Ansible Vault для создания дополнительных пользователей
При этом создан key file:
```
 openssl rand -base64 32 > ~/.ansible/vault.key
```

# ДЗ №9 (ansible-2)


* Создан playbook reddit_app.yml для деплоя приложения reddit(для исключения лишних файлов добавлено расширение \*.retry в файл .gitignore)

* Создан сценарий для настройки базы mongod с помощью модуля template. Добавлен тег db-tag

* Определили переменную для листнера в блоке vars. Значение переменной порта в конфиге темплейта оставили по умолчанию

Сделали тестовый прогон плейбука с помощью команды
```
ansible-playbook reddit_app.yml --check --limit db
```

* Добавлен шаблон в директории templates/db_config.j2, содержащий переменную с адресом db.
Значение этой переменной указали в плейбуке.

* Сделан тестовый и боевой прогон для группы хостов с тегом app-tag
```
ansible-playbook reddit_app.yml --check --limit app --tags app-tag
ansible-playbook reddit_app.yml --limit app --tags app-tag
```
* Установил приложение с помощью модулей git и bundle, пометив тегом deploy-tag, сделав тестовый прогон и применив:
```
ansible-playbook reddit_app.yml --check --limit app --tags deploy-tag
ansible-playbook reddit_app.yml --limit app --tags deploy-tag
```
* Убедились в том, что приложение работает

## Один плейбук несколько сценариев

* Был создан файл rediit_app2.yml , в котором разбили предыдущий сценарий на три группы:Configure MongoDB, Configure App и Deploy. На каждый из них повесели соответствующий тег и указали необходимую группу хостов

* Проверили работоспособность

## Несколько плейбуков

* Разбили файл сценария на три новых файла: app.yml dm.yml deploy.yml
* Удалили соответствующие теги
* Создали общий плейбук site.yml, в котором сослались на три наших плейбука

* Сделали тестовый прогон и задеплоили
```
ansible-playbook site.yml --check
ansible-playbook site.yml
```

* Проверка деплоя:
```
ansible-playbook site.yml

PLAY [Configure MongoDB] ***************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] ********************************************************************************
ok: [dbserver]

PLAY [Configure App] *******************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] **********************************************************************************
ok: [appserver]

TASK [Add config for DB connection] ****************************************************************************
changed: [appserver]

TASK [enable puma] *********************************************************************************************
changed: [appserver]

PLAY [Deploy] **************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ************************************************************
changed: [appserver]

TASK [Bundle install] ******************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] **********************************************************************************
changed: [appserver]

PLAY RECAP *****************************************************************************************************
appserver                  : ok=8    changed=5    unreachable=0    failed=0   
dbserver                   : ok=2    changed=0    unreachable=0    failed=0   
```
# ДЗ №8 (ansible-1)

* Создана инфраструктура из тестового окружения stage
* Созданы  inventory-файлы (yaml format), в которох указаны хосты appserver и dbserver

* С помощью ansible проверили установку приложений ruby и bundler, mongodb
* Создан  простой playbook clone.yml и запущен на выполнение

```
ansible-playbook clone.yml -i inventory.yml

PLAY [Clone] *************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************
ok: [appserver]

TASK [Clone repo] ********************************************************************************************
ok: [appserver]

PLAY RECAP ***************************************************************************************************
appserver                  : ok=2    changed=0    unreachable=0    failed=0   
```
Удалил приложение reddit с помощью команды ansible app -m command -a 'rm -rf ~/reddit' и запустил playbook еще раз, результат:

```
PLAY [Clone] **************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Clone repo] *********************************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP ****************************************************************************************************************************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0
```

Задание со *

Для генерации динамического inventory на лету написан скрипт inventory.py , выводящий список хостов для ansible в формате json.
```
python dynamic_invertory.py

{"app": {"hosts": ["appserver"]}, "all": {"children": ["app", "db"]}, "db": {"hosts": ["dbserver"]}, "_meta": {"hostvars": {"appserver": {"ansible_host": "34.76.207.55"}, "dbserver": {"ansible_host": "35.240.39.153"}}}}
```

# ДЗ №7 (terraform-2)

Монолитное приложение было разделено на следующие модули:
* Модуль app для деплоя приложения puma-server
* Модуль db для деплоя БД
* Модуль VPC с правилом доступа по ssh

Созданы и протестированы окружения prod и stage

Созданы два хранилища - penguin-1 penguin-2 в Google Cloud Storage

## Задание со *

Настроено хранение стейт файла в бакете GCP

В директории terraform создан файл storage-bucket.tf с описанием двух хранилищ(бакетов)
Применяется через terraform init && terraform apply

В окружениях добавлены файлы backend.tf с указанеем хранить файлы в конкретном бакете.

##Задание со **

Приложение разнесено на разные сервера, в модули добавлены необходимые провиженеры.

Через переменную db_local_ip сообщаем приложению где находится ДБ.
(Указанную переменную берем из внутреннего адреса инстанса reddit-db и подставлеяем с помощью переменной окружения DATABASE_URL в файл tmp/puma.env. Таким образом, приложение reddit знает на каком инстансе запущена БД).

# ДЗ №6 (terraform-1)

Выполнено развертование ВМ на основе образа reddit-base при помощи инструмента Terraform.
Конфигурационные файлы параметризованы при помощи переменных.

### задание со *

В метаданных дополнительно объявлен пользователь appuser1 при помощи:
```
metadata {
   ssh-keys = "appuser:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}"
}
```

Для указания нескольких пользовательских ключей используется конструкция:
```
resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
}
```
### Задание со ** - Баллансировка приложения
Создан файл lb.tf в котором описано создание HTTP-балансировщика с помощью методов google_compute_forwarding_rule и google_compute_target_pool.

Добавлен вывод ip-адреса балансировщика через переменную app_external_ip_lb

Для уменьшения количества кода было принято решение увеличивать количество инстансов через каунтер.

# ДЗ №5 (packer-base)
Packer:

Создан базовый образ reddit-base на основании шаблона Ubuntu16.json

Указанный шаблон настроен на работу с переменными, описанными в файле variables.json

В целях безопасности, указанный шаблон добавлен в файл .gitignore , а в репозиторий добавлена его копия variables.json.example

Указанный шаблон проверен при помощи команды

```
packer validate -var-file variables.json ./ubuntu16.json
```

Образ собран с помощью команды

```
packer build -var-file variables.json ./ubuntu16.json
```

На основании шаблона immutable.json создан bake- образ приложения reddit-full-1553641552.

Добавлен старт приложения с помощью systemd.

Также в папку /config-scripts добавлен скрипт create-reddit-vm.sh с возможностью создания и запуска инстанса с помощью команды gcloud.


# HW №3 cloud-bastion

Подключение к someinternalhost в одну команду:  ssh -i ~/.ssh/appuser -At appuser@35.211.5.229 ssh 10.142.0.3

Для подключения из консоли командой ssh someinternalhost и ssh bastion
необходимо внести следующие изменения в файл ~/.ssh/config
на локальном компьютере (создать в случае необходимости):

```
Host bastion
    HostName 35.211.5.229
    User appuser

Host someinternalhost 10.142.0.3
    User appuser
    ProxyCommand ssh -i ~/.ssh/appuser -A bastion nc -w 180 %h %p
```

bastion_IP = 35.211.5.229
someinternalhost_IP = 10.142.0.3

Let's encrypt for pritunl installed, check on:
https://35-211-5-229.sslip.io/login

Cloude-test
testapp_IP = 34.65.55.223
testapp_port = 9292

команда для startup - script:
```
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone europe-west3-a --metadata-from-file startup-script=startup.sh
```

команда для создания правила фаервола:
```
gcloud compute firewall-rules create default-puma-server\
 --direction=INGRESS \
 --priority=1000 \
 --network=default \
 --action=ALLOW \
 --rules=tcp:9292 \
 --source-ranges=0.0.0.0/0 \
 --target-tags=puma-server \
 --description="Allow incoming traffic for puma-server"
```
