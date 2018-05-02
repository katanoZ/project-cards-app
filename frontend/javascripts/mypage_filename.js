//ファイル選択時に、ファイル選択ボタンにファイル名を表示
$(function() {
  $('#mypage_filefield').on('change', display_filename);

  function display_filename(){
    const selected_filename = $('#mypage_filefield').prop('files')[0].name;
    $('#mypage_filename').text(selected_filename);
  };
});
