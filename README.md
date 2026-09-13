# R.E.P.O. 繁體中文翻譯

此倉庫只保存遊戲翻譯資料與更新清單，不包含遊戲檔案、模組 DLL、更新器原始碼或安裝包。

## 內容

- `translations/zh-TW/Text/`：文字翻譯
- `translations/zh-TW/Texture/`：翻譯材質
- `manifest.txt`：供已安裝的翻譯更新器檢查檔案雜湊與大小
- `scripts/Update-Manifest.ps1`：重新產生更新清單
- `scripts/Publish-Translations.ps1`：驗證、提交並推送翻譯更新

## 發布翻譯更新

在 PowerShell 中執行：

```powershell
.\scripts\Publish-Translations.ps1 -Message "更新翻譯"
```

腳本只允許提交本說明、更新清單、兩支 PowerShell 腳本，以及 `translations/` 內的 `.txt`、`.png` 檔案。若發現其他已追蹤或已暫存內容，發布會中止。


