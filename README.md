# ImagePickerPresenting

> POP : Protocol Oriented Programming  協定導向程式設計

### 摘要 ###

* 透過POP的設計模式把 UIImagePickerController ＆ UIAlertController 化繁為簡

###  Source Type ###

>  enum SOURCE_TYPE {
>   case ALL
>    case CAMERA
>    case PHOTO_LIBRARY
> }

* 只要掛了這個Protocol，一行就可以處理好以下的事情
> 1. 使用UIAlertController 詢問要開啟相機還是相簿
> 2. 開啟的同時一併檢查該權限
> 3. 若權限異常則會彈出提醒視窗，並請用戶開啟
> 4. 透過Closure將照片傳回

### 使用方法 ###

> showCameraAlert(type: .ALL) { (image) in
>    self.myImageView.image = image
> }
