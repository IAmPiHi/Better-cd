#include <windows.h>
#include <shobjidl.h>
#include <iostream>
#include <string>
#include <vector> 

#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")

int main() {
    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
    if (FAILED(hr)) return 1;

    IFileOpenDialog *pFileOpen;
    hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL, 
                          IID_IFileOpenDialog, reinterpret_cast<void**>(&pFileOpen));

    if (SUCCEEDED(hr)) {
        DWORD dwOptions;
        if (SUCCEEDED(pFileOpen->GetOptions(&dwOptions))) {
            pFileOpen->SetOptions(dwOptions | FOS_PICKFOLDERS);
        }

        hr = pFileOpen->Show(NULL);

        if (SUCCEEDED(hr)) {
            IShellItem *pItem;
            hr = pFileOpen->GetResult(&pItem);
            if (SUCCEEDED(hr)) {
                PWSTR pszFilePath;
                hr = pItem->GetDisplayName(SIGDN_FILESYSPATH, &pszFilePath);

                if (SUCCEEDED(hr)) {
                    
                    // 將 Unicode (WideChar) 轉換為  ANSI (MultiByte)
                    
                    
                    // 1. 計算轉換後需要的長度
                    int size_needed = WideCharToMultiByte(CP_ACP, 0, pszFilePath, -1, NULL, 0, NULL, NULL);
                    
                    // 2. 準備緩衝區
                    std::vector<char> strTo(size_needed);
                    
                    // 3. 執行轉換
                    WideCharToMultiByte(CP_ACP, 0, pszFilePath, -1, &strTo[0], size_needed, NULL, NULL);
                    
                    // 4. 用標準 cout 輸出 (這樣 Pipe 才能抓到)
                    std::cout << &strTo[0];

                    CoTaskMemFree(pszFilePath);
                }
                pItem->Release();
            }
        }
        pFileOpen->Release();
    }

    CoUninitialize();
    return 0;
}