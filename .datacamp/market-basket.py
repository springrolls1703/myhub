-1Crosselling
-2Identifying_assiciation_rules: using permutations
-3Computing_the_support_metric: onehot encoder



-1Crosselling: checking the products that contains both category
# Count the number of transactions with coffee and gum
coffee = transactions.count(['coffee', 'gum'])

# Count the number of transactions with cereal and gum
cereal = transactions.count(['cereal', 'gum'])

# Count the number of transactions with bread and gum
bread = transactions.count(['bread', 'gum'])

# Print the counts for each transaction.
print('coffee:', coffee)
print('cereal:', cereal)
print('bread:', bread)

-2Identifying_assiciation_rules
# Import pandas under the alias pd
import pandas as pd

# Load transactions from pandas
groceries = pd.read_csv(groceries_path)

# Split transaction strings into lists
transactions = groceries['Transaction'].apply(lambda t: t.split(','))

# Convert DataFrame column into list of strings
transactions = list(transactions)

# Print the list of transactions
print(transactions)

# Import permutations from the itertools module
from itertools import permutations

# Define the set of groceries
flattened = [i for t in transactions for i in t]
groceries = list(set(flattened))

# Generate all possible rules
rules = list(permutations(groceries, 2))

# Print the set of rules
print(rules)

# Print the number of rules
print(len(rules))

-3Computing_the_support_metric
# Import the transaction encoder function from mlxtend
from mlxtend.preprocessing import TransactionEncoder
import pandas as pd

# Instantiate transaction encoder and identify unique items
encoder = TransactionEncoder().fit(transactions)

# One-hot encode transactions
onehot = encoder.transform(transactions)

# Convert one-hot encoded data to DataFrame
onehot = pd.DataFrame(onehot, columns = encoder.columns_)

# Print the one-hot encoded transaction dataset
print(onehot)

# Compute the support
support = onehot.mean()

# Print the support
print(support)
# Add a jam+bread column to the DataFrame onehot
onehot['jam+bread'] = np.logical_and(onehot['jam'], onehot['bread'])

# Compute the support
support = onehot.mean()

# Print the support values
print(support)
