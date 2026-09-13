# 更新翻譯到 GitHub 教學

GitHub 倉庫：<https://github.com/XoF-eLtTiL/REPO-zhtw-Translation>

這套流程只發布翻譯資料，不會發布遊戲檔、BepInEx、DLL、EXE、ZIP、C# 原始碼或建置輸出。

## 第一次使用

1. 安裝 Git 與 GitHub CLI。
2. 開啟 PowerShell，執行：

   ```powershell
   gh auth login
   ```

3. 選擇 `GitHub.com`、`HTTPS`，再依瀏覽器畫面完成登入。
4. 如果還沒有本機資料夾，執行：

   ```powershell
   git clone https://github.com/XoF-eLtTiL/REPO-zhtw-Translation.git
   cd REPO-zhtw-Translation
   ```

目前這台電腦的工作資料夾位於：

```text
C:\Users\a9904\Desktop\zhtw_project\REPO-zhtw-Translation
```

## 可更新的檔案

- 文字翻譯：`translations/zh-TW/Text/*.txt`
- 翻譯材質：`translations/zh-TW/Texture/*.png`
- 翻譯清單：`manifest.txt`，由腳本自動產生，不必手動修改
- 翻譯說明與發布腳本

請勿把遊戲目錄、模組 DLL、更新器原始碼或壓縮安裝包複製進本倉庫。`.gitignore` 與發布腳本都有白名單保護；若偵測到不允許的已追蹤或暫存路徑，發布會中止。

## 每次更新翻譯

1. 編輯 `translations/zh-TW/Text/` 內的翻譯，或替換 `translations/zh-TW/Texture/` 內的翻譯材質。
2. 在倉庫根目錄開啟 PowerShell。
3. 執行：

   ```powershell
   .\scripts\Publish-Translations.ps1 -Message "更新翻譯內容"
   ```

腳本會依序：

1. 確認目前是 `main` 分支與正確的 GitHub 遠端。
2. 重新計算每個翻譯檔的 SHA-256 與大小，更新 `manifest.txt`。
3. 檢查所有已追蹤及暫存路徑是否符合白名單。
4. 執行 Git 格式檢查。
5. 建立提交並推送到 GitHub 的 `main` 分支。

如果沒有任何變更，腳本會顯示 `No translation changes to publish.`，不會建立空提交。

## 只檢查並建立本機提交

想先檢查、不立刻推送時，可執行：

```powershell
.\scripts\Publish-Translations.ps1 -Message "測試翻譯更新" -NoPush
```

確認後再執行：

```powershell
git push origin main
```

## 單獨重新產生 manifest

```powershell
.\scripts\Update-Manifest.ps1
```

成功時會顯示翻譯項目數。manifest 的每一行格式是：

```text
相對路徑|SHA-256|檔案大小
```

遊戲端更新器會讀取：

```text
https://raw.githubusercontent.com/XoF-eLtTiL/REPO-zhtw-Translation/refs/heads/main/manifest.txt
```

並從以下位置下載有變更的翻譯：

```text
https://raw.githubusercontent.com/XoF-eLtTiL/REPO-zhtw-Translation/refs/heads/main/translations/
```

## 常見問題

### GitHub 要求登入

重新執行：

```powershell
gh auth login
```

完成後再執行發布腳本。

### 顯示 `Publish from the main branch only`

先切回主分支：

```powershell
git switch main
```

### 顯示 `Refusing to publish a path outside the translation allowlist`

代表 Git 暫存區或追蹤清單中出現非翻譯相關檔案。先用下列指令查看：

```powershell
git status
```

不要強制略過保護；先確認該檔案是否真的應該公開。

