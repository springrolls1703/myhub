#metrics and terms:
$support
$confidence
$lift
$conviction
$leverage: similar to lift but easier to interpret

-1Crosselling
-2Identifying_assiciation_rules: using permutations
-3Computing_the_support_metric: onehot encoder
-4Refining_support_with_confidence
-5Computing_Lift
-6Computing_conviction
-7Zhangs_metrics



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

-4Refining_support_with_confidence
# Compute support for Hunger and Potter
supportHP = np.logical_and(books['Hunger'], books['Potter']).mean()

# Compute support for Hunger and Twilight
supportHT = np.logical_and(books['Hunger'], books['Twilight']).mean()

# Compute support for Potter and Twilight
supportPT = np.logical_and(books['Potter'], books['Twilight']).mean()

# Print support values
print("Hunger Games and Harry Potter: %.2f" % supportHP)
print("Hunger Games and Twilight: %.2f" % supportHT)
print("Harry Potter and Twilight: %.2f" % supportPT)

# Compute support for Potter and Twilight
supportPT = np.logical_and(books['Potter'], books['Twilight']).mean()

# Compute support for Potter
supportP = books['Potter'].mean()

# Compute support for Twilight
supportT = books['Twilight'].mean()

# Compute confidence for both rules
confidencePT = supportPT / supportP
confidenceTP = supportPT / supportT

# Print results
print('{0:.2f}, {1:.2f}'.format(confidencePT, confidenceTP))

-5Computing_Lift
# Compute support for Potter and Twilight
supportPT = np.logical_and(books['Potter'],books['Twilight']).mean()

# Compute support for Potter
supportP = books['Potter'].mean()

# Compute support for Twilight
supportT = books['Twilight'].mean()

# Compute lift
lift = supportPT / (supportP * supportT)

# Print lift
print("Lift: %.2f" % lift)

-6Computing_conviction
# Compute support for Potter AND Hunger
supportPH = np.logical_and(books['Potter'], books['Hunger']).mean()

# Compute support for Potter
supportP = books['Potter'].mean()

# Compute support for NOT Hunger
supportnH = 1.0 - books['Hunger'].mean()

# Compute support for Potter and NOT Hunger
supportPnH = supportP  - supportPH

# Compute and print conviction for Potter -> Hunger
conviction = supportP * supportnH / supportPnH
print("Conviction: %.2f" % conviction)
--
def conviction(antecedent, consequent):
	# Compute support for antecedent AND consequent
	supportAC = np.logical_and(antecedent, consequent).mean()

	# Compute support for antecedent
	supportA = antecedent.mean()

	# Compute support for NOT consequent
	supportnC = 1.0 - consequent.mean()

	# Compute support for antecedent and NOT consequent
	supportAnC = supportA - supportAC

    # Return conviction
	return supportA * supportnC / supportAnC

-7Zhang's metrics
# Compute the support of Twilight and Harry Potter
supportT = books['Twilight'].mean()
supportP = books['Potter'].mean()

# Compute the support of both books
supportTP = np.logical_and(books['Twilight'],books['Potter']).mean()

# Complete the expressions for the numerator and denominator
numerator = supportTP - supportT*supportP
denominator = max(supportTP*(1-supportT), supportT*(supportP-supportTP))

# Compute and print Zhang's metric
zhang = numerator / denominator
print(zhang)

--

# Define a function to compute Zhang's metric
def zhang(antecedent, consequent):
	# Compute the support of each book
	supportA = antecedent.mean()
	supportC = consequent.mean()

	# Compute the support of both books
	supportAC = np.logical_and(antecedent, consequent).mean()

	# Complete the expressions for the numerator and denominator
	numerator = supportAC - supportA*supportC
	denominator = max(supportAC*(1-supportA), supportA*(supportC-supportAC))

	# Return Zhang's metric
	return numerator / denominator