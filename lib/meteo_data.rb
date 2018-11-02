require 'date'

class MeteoData
  CLOUDINESS = {-1 => 'туман', 0 => 'ясно', 1 => 'малооблачно', 2 => 'облачно', 3 => 'пасмурно'}
  TOD = {0 => 'ночь', 1 => 'утро', 2 => 'день', 3 => 'вечер'}

  attr_reader :parsed_date, :time_of_day, :min_temp, :max_temp, :max_wind, :clouds

  def initialize(forecast)
    @parsed_date = get_parsed_date(forecast)
    @time_of_day = get_tod(forecast)
    @min_temp = get_min_temp(forecast)
    @max_temp = get_max_temp(forecast)
    @max_wind = get_max_wind(forecast)
    @clouds = get_clouds(forecast)
  end

  # Возвращает все данные в многострочном формате
  def to_s
    <<~EOM

    #{parsed_date}, #{time_of_day}
    #{min_temp}..#{max_temp}, ветeр #{max_wind} м/с, #{clouds}
    EOM
  end

  private

  # Возвращает дату в формате ДД.ММ.ГГГГ
  def get_parsed_date(forecast)
    raw_date = "#{forecast.attributes['day']}.#{forecast.attributes['month']}.#{forecast.attributes['year']}"
    parsed_date = Date.parse(raw_date).strftime('%d.%m.%Y')

    # Возвращает "Сегодня", если дата совпадает с текушей
    parsed_date == Date.today ? parsed_date = 'Сегодня' : parsed_date
    parsed_date
  end

  # Возвращает время суток названием
  def get_tod(forecast)
    time_of_day_index = forecast.attributes['tod'].to_i
    TOD[time_of_day_index]
  end

  # Возвращает минимальную температуру с "+", если температура > 0
  def get_min_temp(forecast)
    min_temp = forecast.elements['TEMPERATURE'].attributes['min'].to_i
    "+#{min_temp}" if min_temp > 0
  end

  # Возвращает максимальную температуру с "+", если температура > 0
  def get_max_temp(forecast)
    max_temp = forecast.elements['TEMPERATURE'].attributes['max'].to_i
    "+#{max_temp}" if max_temp > 0
  end

  # Возвращает максимальную силу ветра
  def get_max_wind(forecast)
    forecast.elements['WIND'].attributes['max']
  end

  # Возвращает состояние облачности
  def get_clouds(forecast)
    cloudiness_index = forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
    CLOUDINESS[cloudiness_index]
  end
end