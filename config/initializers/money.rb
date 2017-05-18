Money.default_currency = Money::Currency.new("USD")

#EUR
Money.add_rate("EUR", "USD", 1.36)
Money.add_rate("EUR", "GBP", 0.87)
Money.add_rate("EUR", "CHF", 1.22)
Money.add_rate("EUR", "THB", 43.04)

#GBP
Money.add_rate("GBP", "EUR", 1.15)
Money.add_rate("GBP", "USD", 1.56)
Money.add_rate("GBP", "CHF", 1.40)
Money.add_rate("GBP", "THB", 49.37)

#USD
Money.add_rate("USD", "EUR", 0.73)
Money.add_rate("USD", "GBP", 0.64)
Money.add_rate("USD", "CHF", 0.9)
Money.add_rate("USD", "THB", 30.9)

#CHF
Money.add_rate("CHF", "USD", 1.12)
Money.add_rate("CHF", "GBP", 0.72)
Money.add_rate("CHF", "EUR", 0.82)
Money.add_rate("CHF", "THB", 34.9)

#THB
Money.add_rate("THB", "USD", 0.03)
Money.add_rate("THB", "GBP", 0.02)
Money.add_rate("THB", "EUR", 0.02)
Money.add_rate("THB", "CHF", 0.03)
