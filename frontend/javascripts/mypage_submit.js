//名前変更とファイル選択時に、更新ボタンを使用可能にする
$(window).on('load', function(){
  $('#mypage_name').on('input', enable_submit);
  $('#mypage_filefield').on('change', enable_submit);

  function enable_submit(){
    $('#mypage_submit').removeClass('opacity-02').removeAttr('disabled');
  };
});
