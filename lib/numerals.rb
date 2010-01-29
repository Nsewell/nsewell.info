class Integer

  ROMAN_VALUES = %w(I IV V IX X XL L XC C CD D CM M).zip([1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]).reverse

  def to_roman
    return "-#{(-self).to_roman}" if self < 0
    return '' if self == 0
    ROMAN_VALUES.each do |(i,v)|
      return(i+(self-v).to_roman) if v <= self
    end
  end

end
