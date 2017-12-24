# テクスチャを湿らせる/乾かすシェーダ
## はじめに
以前，人間が画像から湿潤感を認知する際、画素の彩度(Saturation)と輝度(Lightness)が関係していることを述べた論文を超ざっくり紹介した．([参考](https://qiita.com/noroaspe/items/7b313c7e3eec84673a07))

ゲームやメディア作品で使いやすいように，Unityのシェーダ上で実装したので使いたい人は勝手に使ってください．

## 細かい画像処理に関して
### 湿らせる場合
1. テクスチャをRGBからHSLに変換
2. HSL画像のL成分lightを\_Lightness\*light\*light (\_Lightnessは適当な定数) に置換
3. HSL画像のS成分saturationに適当な定数項\_Saturationを加算
4. HSLからRGBに変換

<img src="https://github.com/j20232/WetShader/blob/master/pic/wet1.png" alt="WetTexture1" title="湿ったテクスチャ(左) デフォルト(右)" width="400" height="200">
<img src="https://github.com/j20232/WetShader/blob/master/pic/wet2.png" alt="WetTexture2" title="湿ったテクスチャ(左) デフォルト(右)" width="400" height="200">
(左が湿ったテクスチャ)

### 乾かす場合
1. テクスチャをRGBからHSLに変換
2. HSL画像のL成分lightを\_Lightness\*sqrt(light) (\_Lightnessは適当な定数) に置換
3. HSL画像のS成分saturationに適当な定数項\_Saturationを減算
4. HSLからRGBに変換

<img src="https://github.com/j20232/WetShader/blob/master/pic/dry1.png" alt="DryTexture1" title="乾いたテクスチャ(左) デフォルト(右)" width="400" height="200">
<img src="https://github.com/j20232/WetShader/blob/master/pic/dry2.png" alt="DryTexture2" title="乾いたテクスチャ(左) デフォルト(右)" width="400" height="200">
(左が乾いたテクスチャ)

## License
MIT
