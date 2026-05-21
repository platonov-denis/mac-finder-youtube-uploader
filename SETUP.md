# Загрузчик видео на YouTube

Загрузка видео на YouTube через правую кнопку мыши в Finder.

## Использование

Правая кнопка на видеофайле → **Быстрые действия → Загрузить на YouTube**

- Перед загрузкой проверяется дубликат по MD5-хешу
- Видео загружается в фоне с правами «по ссылке» (unlisted)
- По завершении появляется уведомление, ссылка копируется в буфер обмена
- Все загрузки логируются в `upload.log`

## Структура файлов

```
~/Projects/youtube-uploader/
  youtubeuploader        — бинарник (v1.25.5)
  upload.sh              — скрипт загрузки
  client_secrets.json    — OAuth-ключи (не коммитить в git!)
  token.json             — токен авторизации (создаётся автоматически)
  config.json            — настройки (playlist_id)
  uploaded.json          — база загруженных видео (для проверки дубликатов)
  upload.log             — лог всех загрузок
```

## Лог

```bash
tail -f ~/Projects/youtube-uploader/upload.log
```

Формат итоговой строки:
```
━━━ ГОТОВО: Название | 89M | создан 2026-05-19 14:32 | загружен 2026-05-21 18:52 | время загрузки 1м 24с | https://youtu.be/xxx
```

## Настройка плейлиста

Открой `config.json` и вставь ID плейлиста из URL (`youtube.com/playlist?list=XXX`):
```json
{ "playlist_id": "PL-lXXEHTADXUpgSsknuJJFdxlF4aatEUM" }
```

## Повторная настройка (новый Mac или после сброса)

1. Скопируй `client_secrets.json` в папку проекта
2. Запусти авторизацию:
   ```bash
   cd ~/Projects/youtube-uploader
   ./youtubeuploader -secrets client_secrets.json -cache token.json -filename /путь/к/видео.mp4
   ```
3. Войди в браузере в нужный аккаунт Google
4. Пересоздай Quick Action:
   ```bash
   python3 ~/Projects/youtube-uploader/create_quick_action.py
   ```
