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
-8Overview_of_basket_analysis
-9filtering_support_and_conviction
-10filtering_convition_and_zhang
-11aggregation
-12apriori_algorithm
-13Generating_assoication_rules
-14AggregationandFiltering
-15Applying_Zhang_rules
-16Advancefiltering
-17Visualizing


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

# Define an empty list for Zhang's metric
zhangs_metric = []

# Loop over lists in itemsets
for itemset in itemsets:
    # Extract the antecedent and consequent columns
	antecedent = books[itemset[0]]
	consequent = books[itemset[1]]
    
    # Complete Zhang's metric and append it to the list
	zhangs_metric.append(zhang(antecedent, consequent))
    
# Print results
rules['zhang'] = zhangs_metric
print(rules)

-8Overview_of_basket_analysis
$1Generate_large_set_of_rules
$2Filter_rules_by_using_metrics
$3Apply_intuition_and_common_sense

-9filtering_support_and_conviction
# Preview the rules DataFrame using the .head() method
print(rules.head())

# Select the subset of rules with antecedent support greater than 0.05
rules = rules[rules['antecedent support'] > 0.05]

# Select the subset of rules with a consequent support greater than 0.01
rules = rules[rules['consequent support'] > 0.01]

# Select the subset of rules with a conviction greater than 1.01
rules = rules[rules['conviction'] > 1.01]

# Print remaining rules
print(rules)

-10filtering_convition_and_zhang
# Set the lift threshold to 1.5
rules = rules[rules['lift'] > 1.5]

# Set the conviction threshold to 1.0
rules = rules[rules['conviction'] > 1.0]

# Set the threshold for Zhang's rule to 0.65
rules = rules[rules['zhang'] > 0.65]

# Print rule
print(rules[['antecedents','consequents']])

-11aggregation
# Select the column headers for sign items
sign_headers = [i for i in onehot.columns if i.lower().find('sign')>=0]

# Select columns of sign items
sign_columns = onehot[sign_headers]

# Perform aggregation of sign items into sign category
signs = sign_columns.sum(axis = 1) >= 1.0

# Print support for signs
print('Share of Signs: %.2f' % signs.mean())

--
def aggregate(item):
	# Select the column headers for sign items
	item_headers = [i for i in item.columns if i.lower().find(item)>=0]

	# Select columns of sign items
	item_columns = onehot[item_headers]

	# Return category of aggregated items
	return item_columns.sum(axis = 1) >= 1.0

# Aggregate items for the bags, boxes, and candles categories  
bags = aggregate('bag')
boxes = aggregate('boxes')
candles = aggregate('candles')

def aggregate(item):
	# Select the column headers for sign items
	item_headers = [i for i in onehot.columns if i.lower().find(item)>=0]

	# Select columns of sign items
	item_columns = onehot[item_headers]

	# Return category of aggregated items
	return item_columns.sum(axis = 1) >= 1.0

# Aggregate items for the bags, boxes, and candles categories  
bags = aggregate('bag')
boxes = aggregate('boxes')
candles = aggregate('candles')

-12apriori_algorithm

# Import apriori from mlxtend
from mlxtend.frequent_patterns import apriori

# Compute frequent itemsets using the Apriori algorithm
frequent_itemsets = apriori(onehot, 
                            min_support = 0.005, 
                            max_len = 3, 
                            use_colnames = True)

# Print a preview of the frequent itemsets
print(frequent_itemsets.head())

# Import apriori from mlxtend
from mlxtend.frequent_patterns import apriori

# Compute frequent itemsets using a support of 0.003 and length of 3
frequent_itemsets_1 = apriori(onehot, min_support = 0.003, 
                            max_len = 3, use_colnames = True)

# Compute frequent itemsets using a support of 0.001 and length of 3
frequent_itemsets_2 = apriori(onehot, min_support = 0.001, 
                            max_len = 3, use_colnames = True)

# Print the number of freqeuent itemsets
print(len(frequent_itemsets_1), len(frequent_itemsets_2))

-13Generating_assoication_rules

# Import the association rules function
from mlxtend.frequent_patterns import apriori, association_rules

# Compute frequent itemsets using the Apriori algorithm
frequent_itemsets = apriori(onehot, min_support = 0.001, 
                            max_len = 2, use_colnames = True)

# Compute all association rules for frequent_itemsets
rules = association_rules(frequent_itemsets, 
                            metric = "lift", 
                         	min_threshold = 1)

# Print association rules
print(rules)

# Import the association rules function
from mlxtend.frequent_patterns import apriori, association_rules

# Compute frequent itemsets using the Apriori algorithm
frequent_itemsets = apriori(onehot, min_support= 0.001, 
                            max_len=2, use_colnames = True)

# Compute all association rules using confidence
rules = association_rules(frequent_itemsets, 
                            metric = "confidence", 
                         	min_threshold = 0.5)

# Print association rules
print(rules)


-14AggregationandFiltering
# Apply the apriori algorithm with a minimum support of 0.0
frequent_itemsets = apriori(aggregated, min_support=0.0, use_colnames = True)

# Generate the initial set of rules using a minimum support of 0.0001
rules = association_rules(frequent_itemsets, 
                          metric = "support", min_threshold = 0.0001)

# Set minimum antecedent support to 0.35
rules = rules[rules['antecedent support'] > 0.35]

# Set maximum consequent support to 0.35
rules = rules[rules['consequent support'] < 0.35]

# Print the remaining rules
print(rules)

-15Applying_Zhang_rules
# Generate the initial set of rules using a minimum lift of 1.00
rules = association_rules(frequent_itemsets, metric = "lift", min_threshold = 1.00)

# Set antecedent support to 0.005
rules = rules[rules['antecedent support'] > 0.005]

# Set consequent support to 0.005
rules = rules[rules['consequent support'] > 0.005]

# Compute Zhang's rule
rules['zhang'] = zhangs_rule(rules)

# Set the lower bound for Zhang's rule to 0.98
rules = rules[rules['zhang'] > 0.98]
print(rules[['antecedents', 'consequents']])


-16Advancefiltering
# Apply the Apriori algorithm with a minimum support threshold of 0.001
frequent_itemsets = apriori(onehot, min_support = 0.001, use_colnames = True)

# Recover association rules using a minium support threshold of 0.001
rules = association_rules(frequent_itemsets, metric = 'support', min_threshold = 0.001)

# Apply a 0.002 antecedent support threshold, 0.60 confidence threshold, and 2.50 lift threshold
filtered_rules = rules[(rules['antecedent support'] > 0.002) &
						(rules['consequent support'] > 0.01) &
						(rules['confidence'] > 0.6) &
						(rules['lift'] > 2.50)]

# Print remaining rule
print(filtered_rules[['antecedents','consequents']])


-17Visualizing
# Replace frozen sets with strings
rules['antecedents'] = rules['antecedents'].apply(lambda a: ','.join(list(a)))
rules['consequents'] = rules['consequents'].apply(lambda a: ','.join(list(a)))

# Transform data to matrix format and generate heatmap
pivot = rules.pivot(index='consequents', columns='antecedents', values='support')
sns.heatmap(pivot)

# Format and display plot
plt.yticks(rotation=0)
plt.show()


# Import seaborn under its standard alias
import seaborn as sns

# Transform the DataFrame of rules into a matrix using the lift metric
pivot = rules.pivot(index = 'consequents', 
                   columns = 'antecedents', values= 'lift')

# Generate a heatmap with annotations on and the colorbar off
sns.heatmap(pivot, annot = True, cbar=False)
plt.yticks(rotation=0)
plt.xticks(rotation=90)
plt.show()

# Import seaborn under its standard alias
import seaborn as sns

# Apply the Apriori algorithm with a support value of 0.0075
frequent_itemsets = apriori(onehot, min_support = 0.0075, 
                            use_colnames = True, max_len = 2)

# Generate association rules without performing additional pruning
rules = association_rules(frequent_itemsets, metric = 'support', 
                          min_threshold = 0.0)

# Generate scatterplot using support and confidence
sns.scatterplot(x = "support", y = "confidence", data = rules)
plt.show()

# Import the parallel coordinates plot submodule
from pandas.plotting import parallel_coordinates

# Convert rules into coordinates suitable for use in a parallel coordinates plot
coords = rules_to_coordinates(rules)

# Generate parallel coordinates plot
parallel_coordinates(coords, 'rule', colormap = 'ocean')
plt.legend([])
plt.show()