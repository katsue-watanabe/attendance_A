module ApplicationHelper
  # ページごとにタイトルを返す
  def full_title(page_name = "") # メソッドと引数の定義
    base_title = "AttendanceApp" # 基本となるアプリケーション名を変数に代入
    if page_name.empty?  # 引数を受け取っているか判定
      base_title
    else
      page_name + " | " + base_title
    end
  end
end
