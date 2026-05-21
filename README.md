# 🎬 Mac Finder YouTube Uploader

Загружай видео на YouTube прямо из Finder — правая кнопка мыши, одно нажатие.

![macOS](https://img.shields.io/badge/macOS-15%2B-black?logo=apple)
![YouTube API](https://img.shields.io/badge/YouTube-Data%20API%20v3-red?logo=youtube)
![Shell](https://img.shields.io/badge/shell-bash-green?logo=gnubash)

---

## Как это работает

1. Выбери видеофайл в Finder
2. Правая кнопка → **Быстрые действия → Загрузить на YouTube**
3. Автоматически проверяется дубликат по MD5-хешу
4. Видео загружается в фоне — Finder не блокируется
5. По завершении появляется уведомление и ссылка копируется в буфер обмена

Поддерживается выбор нескольких файлов — загрузятся параллельно.

## Возможности

- **Фоновая загрузка** — работаешь дальше пока видео грузится
- **Проверка дубликатов** — повторная загрузка блокируется по MD5
- **Уведомления macOS** — старт, завершение, ошибка, дубликат
- **Ссылка в буфер** — после загрузки ссылка сразу готова к вставке
- **Лог загрузок** — название, размер, дата создания файла, время загрузки, ссылка
- **Параллельная загрузка** — несколько файлов одновременно

## Требования

- macOS 12+
- [youtubeuploader](https://github.com/porjo/youtubeuploader) — бинарник в папке проекта
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) — `brew install terminal-notifier`
- Google Cloud проект с включённым YouTube Data API v3

## Установка

### 1. Клонируй репозиторий

```bash
git clone https://github.com/platonov-denis/mac-finder-youtube-uploader.git
cd mac-finder-youtube-uploader
```

### 2. Скачай youtubeuploader

```bash
# Apple Silicon
curl -L -o youtubeuploader.tar.gz \
  https://github.com/porjo/youtubeuploader/releases/latest/download/youtubeuploader_1.25.5_Darwin_arm64.tar.gz
tar -xzf youtubeuploader.tar.gz && rm youtubeuploader.tar.gz

# Intel
curl -L -o youtubeuploader.tar.gz \
  https://github.com/porjo/youtubeuploader/releases/latest/download/youtubeuploader_1.25.5_Darwin_amd64.tar.gz
tar -xzf youtubeuploader.tar.gz && rm youtubeuploader.tar.gz
```

### 3. Установи terminal-notifier

```bash
brew install terminal-notifier
```

### 4. Настрой Google Cloud

1. Открой [console.cloud.google.com](https://console.cloud.google.com/)
2. Создай проект → включи **YouTube Data API v3**
3. Создай **OAuth client ID** (тип: Desktop app)
4. Добавь свой аккаунт в тестовые пользователи (Audience → Test users)
5. Скачай JSON и сохрани как `client_secrets.json` в папку проекта

### 5. Авторизуйся

```bash
./youtubeuploader -secrets client_secrets.json -cache token.json -filename /path/to/video.mp4
```

Войди в браузере в аккаунт Google. Если редирект ведёт на `localhost` без порта — добавь `:8080` вручную в адресную строку.

### 6. Укажи плейлист

Открой `config.json` и вставь ID плейлиста из URL (`youtube.com/playlist?list=XXX`):

```json
{ "playlist_id": "PLxxxxxxxxxxxxxxxx" }
```

### 7. Создай Quick Action

```bash
python3 create_quick_action.py
```

Если пункт не появился в меню Finder — перезапусти Finder:

```bash
killall Finder
```

## Структура файлов

```
mac-finder-youtube-uploader/
  upload.sh              — основной скрипт загрузки
  create_quick_action.py — создаёт Automator Quick Action
  config.json            — настройки (playlist_id)
  SETUP.md               — краткая инструкция
  .gitignore

  youtubeuploader        — бинарник (скачать отдельно, не в репо)
  client_secrets.json    — OAuth-ключи (не в репо!)
  token.json             — токен авторизации (не в репо!)
  uploaded.json          — база дубликатов (создаётся автоматически)
  upload.log             — лог загрузок
```

## Решение проблем

**Quick Action пропал из меню:**
```bash
python3 create_quick_action.py && killall Finder
```

**Слетела авторизация:**
```bash
rm token.json
./youtubeuploader -secrets client_secrets.json -cache token.json -filename /path/to/video.mp4
```

**Посмотреть лог в реальном времени:**
```bash
tail -f ~/Projects/youtube-uploader/upload.log
```

## Лицензия

MIT
