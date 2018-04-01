//ファイル選択時に、プレビューを表示
$(function() {
  $('#js-mypage_filefield').on('change', preview_image);

  function preview_image(){
    const selected_file = $('#js-mypage_filefield').prop('files')[0];

    //画像のみ処理
    const imageType = /image.*/;
    if (!selected_file.type.match(imageType)) {
      return;
    }

    //アイコンにプレビュー画像を表示
    const reader = new FileReader();
    reader.readAsDataURL(selected_file);
    reader.onload = function(){
      $('#js-mypage_image').attr('src', reader.result);
    };
  };
});
