require 'webrick'
require 'icalendar'

class MyCal
  def initialize
    @calendar = Icalendar::Calendar.new
    @calendar.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "ミワクルオラクル")
    @calendar.timezone do |t|
      t.tzid = 'Asia/Tokyo'
      t.standard do |s|
        s.tzoffsetfrom = '+0900'
        s.tzoffsetto   = '+0900'
        s.tzname       = 'JST'
        s.dtstart      = '19700101T000000'
      end
    end
    @timetable = ["091500", "111500", "131500", "151500", "171500", "181500"]
    @leaf = %w(
うまくいったらどうなるの？
コーヒーのむ？
カフェオレある？
いまかいまかと待ってました
十年後は部長
わたしくらいになると
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
そう作ってあります
なんでうまくいくんだっけ？
焼2水1🥟
グラスワインの赤🍷
モヒートあります？🌿
    )
    make_today
  end

  def make_today
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
  end

  def to_ical
    @calendar.to_ical
  end 
end

server = WEBrick::HTTPServer.new({:Port => ENV['PORT'].to_i})

server.mount_proc('/') {|req, res|
  res.content_type = 'text/calendar'
  res.body = MyCal.new.to_ical
}

trap(:INT){exit!}
server.start