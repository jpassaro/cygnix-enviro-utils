"""Calculate stuff about a loan.

Intended mostly for use with a vim plugin...

Based around the following formula, to be derived below:
=============================================================================
    P0 = MonthlyPayment * (1 - monthlyIncrease**-n) / (monthlyIncrease - 1)
    MonthlyPayment = P0 * (monthlyIncrease - 1) / (1 - monthlyIncrease**-n)

    n = number of months
    P0 = initial principal
    monthlyIncrease = (1 + ratePerDay) ** 30
=============================================================================



future: newton's method to derive monthly increase (and thence, ratePerDay and APR):
    inc0 = 1 + (MonthlyPayment / P0)
    inc1 - inc0 = alpha * P0 * (1 - inc0**-n - (inc0 - 1)*(n*inc0**-(n+1))) / (1 - inc0**-n)**2
                = alpha * P0 * (1 - inc0**-n - n*inc0**-n + n*inc0**-(n+1)) / (i - inc0**-n)**2
                = alpha * P0 * (1 - inc0**-(n+1) * (inc0*(n+1) - n)) / (i - inc0**-n)**2
    or better?
    P0 * monthlyIncrease - P0 = MonthlyPayment - MonthlyPayment / monthlyIncrease**n
    P0 * monthlyIncrease**(n+1) - (P0 + MonthlyPayment) * monthlyIncrease + MonthlyPayment = 0
    inc0 = 1 + (MonthlyPayment / P0)
    err = P0 * inc**(n+1) - (P0 + MonthlyPayment) * inc + MonthlyPayment
    err' = d(err)/d(inc) = (n+1) * P0 * inc**n - (P0 + MonthlyPayment)
    err' = err / (inc_now - inc_next)
    inc_next = inc_now - (err / err')
    inc_next = inc - (err' / err)
        = inc - ((n+1) * P0 * inc**n - (P0 + MonthlyPayment))
                / (P0 * inc**(n+1) - (P0 + MonthlyPayment) * inc + MonthlyPayment)


To derive the first formula, start with:

    FutureValue = PresentValue * (1 + ratePerDay)**numberOfDays

let monthlyIncrease := (1 + ratePerDay)**30

suppose a given MonthlyPayment:

    P1 = P0 * monthlyIncrease - MonthlyPayment
    P2 = P0 * montlyIncrease**2 - MonthlyPayment*monthlyIncrease - MonthlyPayment
    ...
    Pn = P0 * monthlyIncrease**n - MonthlyPayment * (\sum_i=0^{n-1}monthlyIncrease**i)
       = P0 * monthlyIncreate**n - MonthlyPayment * (monthlyIncrease**n - 1) / (monthlyIncrease - 1)

    Pn := 0
    0 =  P0 * monthlyIncreate**n - MonthlyPayment * (1-monthlyIncrease**n) / (1-monthlyIncrease)
    P0 * monthlyIncrease**n = MonthlyPayment * (1-monthlyIncrease**n) / (1-monthlyIncrease)
divide both sides by monthlyIncrease**n and we have the desired result.

"""


from decimal import Decimal
import inspect
import json
import six
import sys


CALCULATORS = {}


class Calculator(object):
    def __init__(self, f):
        self.func = f
        name = self.name = f.__name__
        if name in CALCULATORS:
            raise ValueError("%r seen twice" % name)

        self.argnames, _, _, defaults = inspect.getargspec(f)
        self.required = self.argnames if defaults is None else \
            {n for n in self.argnames if n not in defaults}

        CALCULATORS[name] = self

    def can_calc(self, obj):
        return all(k in self.required for k in obj.keys())

    def calc_obj(self, obj):
        return self(**{k: v for k, v in obj.items() if k in self.argnames})

    def __call__(self, *args, **kwargs):
        return self.func(*args, **kwargs)

    def add_to(self, obj, agg):
        agg[self.name] = self.calc_obj(obj)
        return agg


def monthlyIncrease(apr):
    apr = Decimal(apr) / 100
    return (1 + (apr / 365)) ** 30

@Calculator
def monthly_payment(balance, term, apr):
    """calculate monthly payment based on balance, length of loan, apr

    MonthlyPayment = P0 *  (monthlyIncrease - 1) / (1 - monthlyIncrease**-n)

    :param balance: principal balance on loan
    :param term: number of months to pay back the loan
    :param apr: annual interest, compounded daily. Entered as a percentage,
        so should be more than zero and less than 100.
    """
    monthly_increase = monthlyIncrease(apr)
    return balance * (monthly_increase - 1) / (1 - monthly_increase ** (-term))


@Calculator
def time_to_repay(balance, apr, monthly_payment):
    """calculate time to pay back a balance given a monthly payment

    (1 - monthlyIncrase ** -n) = P0 * (monthlyIncrease - 1) / monthlyPayment
    1 - (P0 * (monthlyIncrease - 1) / monthlyPayment) = monthlyIncrease ** -n
    -n log(monthlyIncrease) = log(1 - P0 * (monthlyIncrease - 1) / monthlyPayment)
    n = -log_{monthlyIncrease}(1 - P0 * (monthlyIncrease - 1) / monthlyPayment)
    """
    monthly_increase = monthlyIncrease(apr)
    return -(
        1 - (balance * (monthly_increase - 1) / monthly_payment)
    ).ln() / monthly_increase.ln()


if __name__ == '__main__':
    with (open(sys.argv[1]) if sys.argv[1:] else sys.stdin) as f:
        obj = json.load(f, parse_float=Decimal)
    for calculator in CALCULATORS.values():
        if calculator.can_calc(obj):
            six.print_(calculator.name, ': ', calculator.calc_obj(obj), sep='')
