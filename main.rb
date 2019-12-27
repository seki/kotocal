require 'webrick'
require 'icalendar'

class MyCal
  def initialize
    @timetable = ["091500", "111500", "131500", "151500", "171500", "181500"]
    @leaf = %w(
くくく
再現しました
強く押したら動いた
無意識だからわからない
ぜったい再現させるつもりで
書いてあるテストじゃバグ出ないよね
うまくいったらどうなるの？
わたしくらいになると
そうなの？
多数決で決める？
できそう？
再現させたらわかるの？
なにが大事じゃないの？
がんばらないで！
なんでやるんだっけ？
見せて
これはダメなやつだ
なにもしてないの？
なにしてるの？
様子見ない
そう作ってあります？
なんでうまくいくんだっけ？
いつテストしてるの？
スッとしたー
時を感じなかった
真似してもいいよ
ふつうにやってた！
よーし！
連打してたわ
ダー、ダカダーン、ダカダン、ダカダン
    )
    make_today
  end

  def make_today
    @calendar = Icalendar::Calendar.new
    @calendar.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "71956")
    @calendar.timezone do |t|
      t.tzid = 'Asia/Tokyo'
      t.standard do |s|
        s.tzoffsetfrom = '+0900'
        s.tzoffsetto   = '+0900'
        s.tzname       = 'JST'
        s.dtstart      = '19700101T000000'
      end
    end

    today = Date.today.strftime("%Y%m%d")
    # Random.srand(today.to_i)
    size = @timetable.size - 2
    leaf = @leaf.sort_by {rand}[0, size] + ["もうやめなよ"]

    @timetable.each_cons(2) do |dts, dte|
      dts = [today, dts].join("T")
      dte = [today, dte].join("T")

      @calendar.event do |e|
        e.dtstart = Icalendar::Values::DateOrDateTime.new(dts)
        e.dtend = Icalendar::Values::DateOrDateTime.new(dte)
        e.summary = leaf.shift
        e.alarm do |a|
          a.trigger = "-PT10M"
          a.summary = "じー"
        end
      end
    end
    @today = today
  end

  def to_ical
    make_today if expired?
    @calendar.to_ical
  end

  def expired?
    @today != Date.today.strftime("%Y%m%d")
  end
end

server = WEBrick::HTTPServer.new({:Port => ENV['PORT'].to_i})
mycal = MyCal.new

server.mount_proc('/') {|req, res|
  res.content_type = 'text/calendar'
  res.body = mycal.to_ical
}

trap(:INT){exit!}
server.start