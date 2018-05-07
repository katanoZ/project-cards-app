//ファイル選択時に、ファイル選択ボタンにファイル名を表示
$(function() {
  $('#js-mypage_filefield').on('change', display_filename);

  function display_filename(){
    const selected_filename = $('#js-mypage_filefield').prop('files')[0].name;
    $('#js-mypage_filename').text(selected_filename);
  };
});
