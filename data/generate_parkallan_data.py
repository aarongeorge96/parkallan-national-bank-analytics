"""
Parkallan National Bank — Retail Analytics Platform
Data Generation Script
Generates realistic Canadian retail banking data and exports to CSV files.
"""

import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import date, timedelta
import os

fake = Faker('en_CA')
random.seed(42)
np.random.seed(42)

OUTPUT_DIR = 'parkallan_data'
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ── CONFIG ────────────────────────────────────────────────────────────────────
N_CUSTOMERS     = 5000
N_LOCATIONS     = 50
N_TRANSACTIONS  = 500000
N_LOANS         = 5000
START_DATE      = date(2022, 1, 1)
END_DATE        = date(2023, 12, 31)

print("Parkallan National Bank — Data Generation Starting...")
print("=" * 60)

# ── CANADIAN HOLIDAYS (2022-2023) ─────────────────────────────────────────────
CANADIAN_HOLIDAYS = {
    date(2022, 1, 1), date(2022, 2, 21), date(2022, 4, 15), date(2022, 4, 18),
    date(2022, 5, 23), date(2022, 7, 1), date(2022, 8, 1), date(2022, 9, 5),
    date(2022, 10, 10), date(2022, 11, 11), date(2022, 12, 25), date(2022, 12, 26),
    date(2023, 1, 1), date(2023, 2, 20), date(2023, 4, 7), date(2023, 4, 10),
    date(2023, 5, 22), date(2023, 7, 1), date(2023, 8, 7), date(2023, 9, 4),
    date(2023, 10, 9), date(2023, 11, 11), date(2023, 12, 25), date(2023, 12, 26),
}

# ── DIM DATE ─────────────────────────────────────────────────────────────────
print("Generating dim_date...")
dates = pd.date_range(start=START_DATE, end=END_DATE)
dim_date = pd.DataFrame({'full_date': dates})
dim_date['date_id']             = dim_date['full_date'].dt.strftime('%Y%m%d').astype(int)
dim_date['day']                 = dim_date['full_date'].dt.day
dim_date['month']               = dim_date['full_date'].dt.month
dim_date['month_name']          = dim_date['full_date'].dt.strftime('%B')
dim_date['quarter']             = dim_date['full_date'].dt.quarter
dim_date['year']                = dim_date['full_date'].dt.year
dim_date['day_of_week']         = dim_date['full_date'].dt.strftime('%A')
dim_date['is_weekend']          = dim_date['full_date'].dt.dayofweek >= 5
dim_date['is_canadian_holiday'] = dim_date['full_date'].dt.date.isin(CANADIAN_HOLIDAYS)
dim_date['fiscal_quarter']      = 'Q' + dim_date['quarter'].astype(str)
dim_date['full_date']           = dim_date['full_date'].dt.date
dim_date = dim_date[['date_id','full_date','day','month','month_name','quarter',
                      'year','day_of_week','is_weekend','is_canadian_holiday','fiscal_quarter']]
dim_date.to_csv(f'{OUTPUT_DIR}/dim_date.csv', index=False)
print(f"  ✓ dim_date: {len(dim_date)} rows")

# ── DIM PRODUCTS ──────────────────────────────────────────────────────────────
print("Generating dim_products...")
products = [
    (1,  'Chequing Account',       'Deposit',    'Everyday Banking',  False, 'None',     0,   'Low',    0,      False, True,  16.95),
    (2,  'Savings Account',        'Deposit',    'Everyday Banking',  False, 'Variable', 0,   'Low',    0,      False, True,  0.00),
    (3,  'GIC',                    'Investment', 'Term Investment',   False, 'Fixed',    12,  'Low',    0,      False, True,  0.00),
    (4,  'TFSA',                   'Investment', 'Registered',        False, 'Variable', 0,   'Low',    0,      True,  True,  0.00),
    (5,  'RRSP',                   'Investment', 'Registered',        False, 'Variable', 0,   'Low',    0,      True,  True,  0.00),
    (6,  'Credit Card',            'Credit',     'Revolving Credit',  True,  'Fixed',    0,   'Medium', 30000,  False, True,  0.00),
    (7,  'Personal Loan',          'Credit',     'Unsecured Credit',  True,  'Fixed',    60,  'Medium', 30000,  False, True,  0.00),
    (8,  'Mortgage',               'Credit',     'Secured Credit',    True,  'Fixed',    300, 'High',   60000,  False, True,  0.00),
    (9,  'HELOC',                  'Credit',     'Secured Credit',    True,  'Variable', 0,   'High',   60000,  False, True,  0.00),
    (10, 'Overdraft Protection',   'Credit',     'Everyday Banking',  True,  'Fixed',    0,   'Low',    0,      False, True,  4.95),
]
dim_products = pd.DataFrame(products, columns=[
    'product_id','product_name','product_category','product_type','is_credit',
    'interest_rate_type','typical_term_months','risk_tier','min_income_required',
    'is_registered','is_active_product','monthly_fee'
])
dim_products.to_csv(f'{OUTPUT_DIR}/dim_products.csv', index=False)
print(f"  ✓ dim_products: {len(dim_products)} rows")

# ── DIM LOCATION ──────────────────────────────────────────────────────────────
print("Generating dim_location...")
canadian_cities = [
    ('Toronto', 'Ontario', 'M5H 2N2', 'Central Canada'),
    ('Toronto', 'Ontario', 'M4B 1B3', 'Central Canada'),
    ('Toronto', 'Ontario', 'M6G 1B1', 'Central Canada'),
    ('Ottawa', 'Ontario', 'K1P 5G8', 'Central Canada'),
    ('Mississauga', 'Ontario', 'L5B 3C1', 'Central Canada'),
    ('Hamilton', 'Ontario', 'L8P 4S8', 'Central Canada'),
    ('Montreal', 'Quebec', 'H3A 0G4', 'Central Canada'),
    ('Montreal', 'Quebec', 'H2X 1Y6', 'Central Canada'),
    ('Quebec City', 'Quebec', 'G1R 4S9', 'Central Canada'),
    ('Laval', 'Quebec', 'H7T 2P5', 'Central Canada'),
    ('Calgary', 'Alberta', 'T2P 2M7', 'Western Canada'),
    ('Calgary', 'Alberta', 'T3A 0A1', 'Western Canada'),
    ('Edmonton', 'Alberta', 'T5J 1W9', 'Western Canada'),
    ('Edmonton', 'Alberta', 'T6G 2R3', 'Western Canada'),
    ('Red Deer', 'Alberta', 'T4N 3M4', 'Western Canada'),
    ('Lethbridge', 'Alberta', 'T1J 4L1', 'Western Canada'),
    ('Vancouver', 'British Columbia', 'V6C 3E8', 'Western Canada'),
    ('Vancouver', 'British Columbia', 'V5K 1A1', 'Western Canada'),
    ('Surrey', 'British Columbia', 'V3T 1W7', 'Western Canada'),
    ('Burnaby', 'British Columbia', 'V5H 4M9', 'Western Canada'),
    ('Victoria', 'British Columbia', 'V8W 1P6', 'Western Canada'),
    ('Kelowna', 'British Columbia', 'V1Y 6N6', 'Western Canada'),
    ('Winnipeg', 'Manitoba', 'R3C 4T3', 'Prairie'),
    ('Winnipeg', 'Manitoba', 'R2H 0G5', 'Prairie'),
    ('Brandon', 'Manitoba', 'R7A 6A9', 'Prairie'),
    ('Saskatoon', 'Saskatchewan', 'S7K 1J5', 'Prairie'),
    ('Regina', 'Saskatchewan', 'S4P 4K7', 'Prairie'),
    ('Halifax', 'Nova Scotia', 'B3J 3T2', 'Atlantic Canada'),
    ('Halifax', 'Nova Scotia', 'B3H 1A1', 'Atlantic Canada'),
    ('Dartmouth', 'Nova Scotia', 'B2Y 3Z7', 'Atlantic Canada'),
    ('Moncton', 'New Brunswick', 'E1C 8R3', 'Atlantic Canada'),
    ('Fredericton', 'New Brunswick', 'E3B 5G4', 'Atlantic Canada'),
    ('Saint John', 'New Brunswick', 'E2L 4L5', 'Atlantic Canada'),
    ('Charlottetown', 'Prince Edward Island', 'C1A 4N5', 'Atlantic Canada'),
    ("St. John's", 'Newfoundland and Labrador', 'A1C 5S7', 'Atlantic Canada'),
    ('Whitehorse', 'Yukon', 'Y1A 2C6', 'Northern'),
    ('Yellowknife', 'Northwest Territories', 'X1A 2N5', 'Northern'),
    ('Iqaluit', 'Nunavut', 'X0A 0H0', 'Northern'),
    ('Kitchener', 'Ontario', 'N2G 4L2', 'Central Canada'),
    ('London', 'Ontario', 'N6A 3N7', 'Central Canada'),
    ('Windsor', 'Ontario', 'N9A 1E1', 'Central Canada'),
    ('Barrie', 'Ontario', 'L4M 3B1', 'Central Canada'),
    ('Kingston', 'Ontario', 'K7L 2Z7', 'Central Canada'),
    ('Sudbury', 'Ontario', 'P3E 3B8', 'Central Canada'),
    ('Thunder Bay', 'Ontario', 'P7B 5E1', 'Central Canada'),
    ('Abbotsford', 'British Columbia', 'V2S 6H1', 'Western Canada'),
    ('Prince George', 'British Columbia', 'V2L 3H5', 'Western Canada'),
    ('Nanaimo', 'British Columbia', 'V9R 5S5', 'Western Canada'),
    ('Medicine Hat', 'Alberta', 'T1A 0B4', 'Western Canada'),
    ('Fort McMurray', 'Alberta', 'T9H 1S8', 'Western Canada'),
]

income_tiers = ['High', 'Middle', 'Low']
locations = []
for i, (city, province, postal, region) in enumerate(canadian_cities):
    locations.append({
        'location_id': i + 1,
        'street_address': fake.street_address(),
        'city': city,
        'province': province,
        'postal_code': postal,
        'region': region,
        'neighborhood_income_tier': random.choices(income_tiers, weights=[0.2, 0.5, 0.3])[0],
        'is_branch': True
    })

# Add customer address locations (not branches)
for i in range(200):
    city, province, postal, region = random.choice(canadian_cities)
    locations.append({
        'location_id': 51 + i,
        'street_address': fake.street_address(),
        'city': city,
        'province': province,
        'postal_code': fake.postalcode(),
        'region': region,
        'neighborhood_income_tier': random.choices(income_tiers, weights=[0.2, 0.5, 0.3])[0],
        'is_branch': False
    })

dim_location = pd.DataFrame(locations)
dim_location.to_csv(f'{OUTPUT_DIR}/dim_location.csv', index=False)
print(f"  ✓ dim_location: {len(dim_location)} rows")

# ── DIM CUSTOMERS ─────────────────────────────────────────────────────────────
print("Generating dim_customers...")
occupations = ['Engineer', 'Teacher', 'Nurse', 'Manager', 'Accountant', 'Retail Worker',
               'Truck Driver', 'Software Developer', 'Doctor', 'Lawyer', 'Retired',
               'Student', 'Construction Worker', 'Business Owner', 'Government Employee']
income_brackets = ['<30K', '30K-60K', '60K-100K', '100K-200K', '200K+']
income_weights  = [0.15, 0.30, 0.30, 0.20, 0.05]
segments        = ['Mass Market', 'Emerging Affluent', 'High Net Worth', 'Private Banking']
segment_weights = [0.60, 0.25, 0.12, 0.03]
channels        = ['Branch', 'Online', 'Referral', 'Mobile App']
channel_weights = [0.35, 0.30, 0.15, 0.20]
genders         = ['Male', 'Female', 'Non-binary']
gender_weights  = [0.48, 0.48, 0.04]

customer_location_ids = [loc['location_id'] for loc in locations if not loc['is_branch']]

customers = []
for i in range(N_CUSTOMERS):
    dob = fake.date_of_birth(minimum_age=18, maximum_age=85)
    income = random.choices(income_brackets, weights=income_weights)[0]
    segment_map = {
        '<30K': 'Mass Market', '30K-60K': 'Mass Market',
        '60K-100K': random.choices(['Mass Market', 'Emerging Affluent'], weights=[0.5, 0.5])[0],
        '100K-200K': random.choices(['Emerging Affluent', 'High Net Worth'], weights=[0.6, 0.4])[0],
        '200K+': random.choices(['High Net Worth', 'Private Banking'], weights=[0.6, 0.4])[0],
    }
    customers.append({
        'customer_id':          i + 1,
        'first_name':           fake.first_name(),
        'last_name':            fake.last_name(),
        'dob':                  dob,
        'gender':               random.choices(genders, weights=gender_weights)[0],
        'sin':                  f'***-***-{random.randint(1000,9999)}',
        'phone':                fake.phone_number(),
        'email':                fake.email(),
        'occupation':           random.choice(occupations),
        'income_bracket':       income,
        'customer_segment':     segment_map[income],
        'acquisition_channel':  random.choices(channels, weights=channel_weights)[0],
        'location_id':          random.choice(customer_location_ids),
        'created_at':           fake.date_between(start_date=date(2015, 1, 1), end_date=START_DATE),
        'is_active':            random.choices([True, False], weights=[0.92, 0.08])[0],
    })

dim_customers = pd.DataFrame(customers)
dim_customers.to_csv(f'{OUTPUT_DIR}/dim_customers.csv', index=False)
print(f"  ✓ dim_customers: {len(dim_customers)} rows")

# ── FACT ACCOUNTS ─────────────────────────────────────────────────────────────
print("Generating fact_accounts...")
branch_location_ids = [loc['location_id'] for loc in locations if loc['is_branch']]
date_ids = dim_date['date_id'].tolist()
all_dates = dim_date['full_date'].tolist()

accounts = []
account_id = 1
for cust in customers:
    # Each customer gets 2-5 products
    n_products = random.choices([2, 3, 4, 5], weights=[0.2, 0.4, 0.3, 0.1])[0]
    # Always give chequing account
    product_pool = [1] + random.sample(range(2, 11), min(n_products - 1, 9))

    for prod_id in product_pool:
        product = dim_products[dim_products['product_id'] == prod_id].iloc[0]
        open_date = fake.date_between(start_date=cust['created_at'], end_date=END_DATE)
        is_closed = random.choices([True, False], weights=[0.08, 0.92])[0]
        close_date = None
        if is_closed:
            close_date = fake.date_between(start_date=open_date, end_date=END_DATE)

        balance = 0
        credit_limit = None
        original_amount = None

        if prod_id in [1, 2]:
            balance = round(random.uniform(100, 50000), 2)
        elif prod_id in [3, 4, 5]:
            balance = round(random.uniform(1000, 200000), 2)
        elif prod_id == 6:
            credit_limit = random.choice([1000, 2500, 5000, 10000, 15000, 25000, 50000])
            balance = round(random.uniform(0, credit_limit * 0.7), 2)
        elif prod_id == 7:
            original_amount = round(random.uniform(5000, 50000), 2)
            balance = round(original_amount * random.uniform(0.1, 0.9), 2)
        elif prod_id == 8:
            original_amount = round(random.uniform(200000, 1200000), 2)
            balance = round(original_amount * random.uniform(0.5, 0.98), 2)
        elif prod_id == 9:
            credit_limit = round(random.uniform(50000, 300000), 2)
            balance = round(random.uniform(0, credit_limit * 0.5), 2)

        open_date_id = int(open_date.strftime('%Y%m%d'))
        close_date_id = int(close_date.strftime('%Y%m%d')) if close_date else None

        accounts.append({
            'account_id':               account_id,
            'customer_id':              cust['customer_id'],
            'product_id':               prod_id,
            'location_id':              random.choice(branch_location_ids),
            'open_date_id':             open_date_id,
            'close_date_id':            close_date_id,
            'account_status':           'Closed' if is_closed else 'Active',
            'current_balance':          balance,
            'credit_limit':             credit_limit,
            'original_amount':          original_amount,
            'relationship_manager_id':  random.randint(1, 100),
            'overdraft_limit':          500.00 if prod_id == 1 else None,
            'last_activity_date':       fake.date_between(start_date=open_date, end_date=END_DATE),
        })
        account_id += 1

fact_accounts = pd.DataFrame(accounts)
fact_accounts.to_csv(f'{OUTPUT_DIR}/fact_accounts.csv', index=False)
print(f"  ✓ fact_accounts: {len(fact_accounts)} rows")

# ── FACT TRANSACTIONS ─────────────────────────────────────────────────────────
print("Generating fact_transactions... (this may take a moment)")

# Only use chequing and credit card accounts for transactions
txn_accounts = fact_accounts[fact_accounts['product_id'].isin([1, 6])].copy()

categories = {
    'Groceries':                ('5411', ['Sobeys', 'Loblaws', 'No Frills', 'FreshCo', 'Metro', 'Safeway', 'Real Canadian Superstore']),
    'Dining & Entertainment':   ('5812', ['Tim Hortons', 'McDonald\'s', 'Swiss Chalet', 'Boston Pizza', 'A&W', 'Harvey\'s']),
    'Utilities':                ('4900', ['Enmax', 'BC Hydro', 'Toronto Hydro', 'Hydro Quebec', 'Epcor']),
    'Rent/Mortgage Payment':    ('6552', ['Property Management Co', 'Landlord Payment']),
    'Transportation':           ('5541', ['Petro-Canada', 'Shell', 'Esso', 'Uber', 'Transit Payment']),
    'Healthcare':               ('8099', ['Shoppers Drug Mart', 'Rexall', 'Medical Clinic']),
    'Shopping':                 ('5999', ['Canadian Tire', 'Winners', 'Hudson\'s Bay', 'Sport Chek', 'IKEA']),
    'Travel':                   ('4722', ['Air Canada', 'WestJet', 'Expedia', 'Marriott', 'Delta Hotels']),
    'ATM Withdrawal':           ('6011', ['Parkallan ATM']),
    'Transfer':                 ('6000', ['Interac e-Transfer']),
    'Payroll Deposit':          ('6999', ['Employer Payroll']),
    'Government Benefit':       ('9399', ['Service Canada', 'CRA Deposit']),
}

cat_names     = list(categories.keys())
cat_weights   = [0.20, 0.15, 0.08, 0.10, 0.10, 0.05, 0.12, 0.03, 0.07, 0.05, 0.03, 0.02]
channels_txn  = ['POS', 'Online', 'ATM', 'Mobile', 'Branch']
ch_weights    = [0.40, 0.30, 0.10, 0.15, 0.05]
currencies    = ['CAD', 'USD']
curr_weights  = [0.95, 0.05]
statuses      = ['Completed', 'Failed', 'Reversed']
stat_weights  = [0.96, 0.03, 0.01]
failure_reasons = ['Insufficient Funds', 'Card Declined', 'Incorrect PIN', 'Expired Card']

amount_ranges = {
    'Groceries': (15, 300), 'Dining & Entertainment': (10, 150),
    'Utilities': (50, 400), 'Rent/Mortgage Payment': (800, 3500),
    'Transportation': (20, 200), 'Healthcare': (10, 300),
    'Shopping': (20, 500), 'Travel': (200, 3000),
    'ATM Withdrawal': (20, 500), 'Transfer': (50, 5000),
    'Payroll Deposit': (1500, 8000), 'Government Benefit': (500, 2000),
}

txn_account_list = txn_accounts.to_dict('records')
transactions = []

for i in range(N_TRANSACTIONS):
    acc = random.choice(txn_account_list)
    cat = random.choices(cat_names, weights=cat_weights)[0]
    mcc, merchants = categories[cat]
    merchant = random.choice(merchants)
    amount_min, amount_max = amount_ranges[cat]
    amount = round(random.uniform(amount_min, amount_max), 2)
    txn_type = 'Credit' if cat in ['Payroll Deposit', 'Government Benefit', 'Transfer'] else 'Debit'
    status = random.choices(statuses, weights=stat_weights)[0]
    currency = random.choices(currencies, weights=curr_weights)[0]
    channel = random.choices(channels_txn, weights=ch_weights)[0]
    txn_date = fake.date_between(start_date=START_DATE, end_date=END_DATE)
    date_id = int(txn_date.strftime('%Y%m%d'))

    transactions.append({
        'transaction_id':           i + 1,
        'account_id':               acc['account_id'],
        'customer_id':              acc['customer_id'],
        'date_id':                  date_id,
        'location_id':              random.choice(branch_location_ids),
        'transaction_amount':       amount,
        'transaction_type':         txn_type,
        'transaction_category':     cat,
        'merchant_name':            merchant,
        'merchant_category_code':   mcc,
        'channel':                  channel,
        'transaction_status':       status,
        'failure_reason':           random.choice(failure_reasons) if status == 'Failed' else None,
        'currency':                 currency,
        'exchange_rate':            round(random.uniform(1.30, 1.40), 4) if currency == 'USD' else 1.0,
        'is_foreign':               currency != 'CAD',
        'is_flagged':               random.choices([True, False], weights=[0.02, 0.98])[0],
    })

fact_transactions = pd.DataFrame(transactions)
fact_transactions.to_csv(f'{OUTPUT_DIR}/fact_transactions.csv', index=False)
print(f"  ✓ fact_transactions: {len(fact_transactions)} rows")

# ── FACT LOANS ────────────────────────────────────────────────────────────────
print("Generating fact_loans...")
loan_products   = [7, 8, 9]  # Personal Loan, Mortgage, HELOC
loan_statuses   = ['Current', 'Delinquent', 'Defaulted', 'Paid Off']
loan_stat_w     = [0.82, 0.08, 0.04, 0.06]
rejection_reasons = ['Low Credit Score', 'Insufficient Income', 'High Debt-to-Income Ratio',
                     'Incomplete Application', 'Employment History']
collateral_types = {'Mortgage': 'Property', 'HELOC': 'Property', 'Personal Loan': None}

loans = []
customer_sample = random.sample(customers, N_LOANS)

for i, cust in enumerate(customer_sample):
    prod_id = random.choice(loan_products)
    product = dim_products[dim_products['product_id'] == prod_id].iloc[0]
    app_date = fake.date_between(start_date=START_DATE, end_date=END_DATE)
    credit_score = int(np.clip(np.random.normal(680, 80), 300, 900))
    approval_prob = min(0.95, max(0.05, (credit_score - 300) / 600))
    approved = random.random() < approval_prob
    status = random.choices(['Approved', 'Rejected', 'Pending'], weights=[0.75, 0.20, 0.05])[0]

    requested = None
    approved_amount = None
    interest_rate = None
    term_months = None
    monthly_payment = None
    outstanding = None
    total_paid = None
    is_secured = False
    collateral_type = None
    collateral_value = None
    approval_date_id = None
    loan_status = None
    missed = 0
    dpd = 0

    if prod_id == 7:
        requested = round(random.uniform(5000, 50000), 2)
        term_months = random.choice([24, 36, 48, 60])
        is_secured = False
    elif prod_id == 8:
        requested = round(random.uniform(200000, 1200000), 2)
        term_months = random.choice([240, 300])
        is_secured = True
        collateral_type = 'Property'
        collateral_value = round(requested * random.uniform(1.1, 1.5), 2)
    elif prod_id == 9:
        requested = round(random.uniform(50000, 300000), 2)
        term_months = 0
        is_secured = True
        collateral_type = 'Property'
        collateral_value = round(requested * random.uniform(1.5, 2.5), 2)

    if status == 'Approved':
        approved_amount = round(requested * random.uniform(0.85, 1.0), 2)
        interest_rate = round(random.uniform(4.5, 12.0) if prod_id == 7 else random.uniform(4.0, 7.5), 2)
        approval_date = fake.date_between(start_date=app_date, end_date=min(app_date + timedelta(days=30), END_DATE))
        approval_date_id = int(approval_date.strftime('%Y%m%d'))
        if term_months and term_months > 0:
            r = (interest_rate / 100) / 12
            monthly_payment = round(approved_amount * r / (1 - (1 + r) ** (-term_months)), 2)
        total_paid = round(approved_amount * random.uniform(0.01, 0.3), 2)
        outstanding = round(approved_amount - total_paid, 2)
        loan_status = random.choices(loan_statuses, weights=loan_stat_w)[0]
        missed = random.choices([0, 1, 2, 3], weights=[0.85, 0.08, 0.04, 0.03])[0]
        dpd = missed * 30

    loans.append({
        'loan_id':                      i + 1,
        'customer_id':                  cust['customer_id'],
        'product_id':                   prod_id,
        'location_id':                  random.choice(branch_location_ids),
        'application_date_id':          int(app_date.strftime('%Y%m%d')),
        'approval_date_id':             approval_date_id,
        'loan_amount_requested':        requested,
        'loan_amount_approved':         approved_amount,
        'approval_status':              status,
        'rejection_reason':             random.choice(rejection_reasons) if status == 'Rejected' else None,
        'interest_rate':                interest_rate,
        'interest_rate_type':           product['interest_rate_type'],
        'loan_term_months':             term_months,
        'monthly_payment':              monthly_payment,
        'outstanding_balance':          outstanding,
        'total_paid':                   total_paid,
        'is_secured':                   is_secured,
        'collateral_type':              collateral_type,
        'collateral_value':             collateral_value,
        'credit_score_at_application':  credit_score,
        'loan_status':                  loan_status,
        'missed_payments_count':        missed,
        'days_past_due':                dpd,
    })

fact_loans = pd.DataFrame(loans)
fact_loans.to_csv(f'{OUTPUT_DIR}/fact_loans.csv', index=False)
print(f"  ✓ fact_loans: {len(fact_loans)} rows")

# ── SUMMARY ───────────────────────────────────────────────────────────────────
print()
print("=" * 60)
print("DATA GENERATION COMPLETE")
print("=" * 60)
print(f"Output directory: {OUTPUT_DIR}/")
print()
print("Files generated:")
for fname in os.listdir(OUTPUT_DIR):
    fpath = os.path.join(OUTPUT_DIR, fname)
    size = os.path.getsize(fpath) / 1024
    rows = sum(1 for _ in open(fpath)) - 1
    print(f"  {fname:<35} {rows:>7} rows   {size:>8.1f} KB")
