# Sample Product discount promotion in the format of (1,'Discount value') as product discount applied with any quantity
product_discount1 = [(1,10000)]
product_discount2 = [(1,12000)]

# Sample Quantity based discount promotion in the format of ('From Quantity','Discount value')
quantity_based_discount1 = [(1,5000),(11,11000),(13,10000),(31,30000)]
quantity_based_discount2 = [(1,14000),(11,10000),(13,13000),(30,10000)]

# Combine all promotions of one type
all_product_discount = product_discount1 + product_discount2
all_quantity_based_discount = quantity_based_discount1 + quantity_based_discount2

# Find the highest highest_possiple_product_discount
highest_product_discount_value = 0
highest_quantity_based_discount_value = 0
display_style = ''
final_discount = []


for i in range(len(all_product_discount)):
    if all_product_discount[i][1] > highest_product_discount_value:
        highest_product_discount_value = all_product_discount[i][1]

for i in range(len(all_quantity_based_discount)):
    if all_quantity_based_discount[i][1] > highest_quantity_based_discount_value:
        highest_quantity_based_discount_value = all_quantity_based_discount[i][1]

if highest_product_discount_value >= highest_quantity_based_discount_value:
    display_style = 'Product discount'
    final_discount = final_discount + [tuple([1,highest_product_discount_value])]
else:
    display_style = 'Quantity based discount'
    sorted_all_quantity_based_discount = sorted(all_quantity_based_discount, key=lambda tup: tup[0])
    current_from_quantity = 1
    current_discount = highest_product_discount_value
    for i in range(len(all_quantity_based_discount)):                
        viewing_from_quantity = sorted_all_quantity_based_discount[i][0]        
        viewing_discount = sorted_all_quantity_based_discount[i][1]
        if viewing_from_quantity == current_from_quantity: 
            if viewing_discount > current_discount:                
                current_discount = viewing_discount
            else:
                continue
        elif viewing_from_quantity > current_from_quantity:                                
            if (viewing_discount > current_discount) or (viewing_discount <= current_discount and viewing_discount > highest_product_discount_value):   
                final_discount = final_discount + [tuple([current_from_quantity,current_discount])]
                current_discount = viewing_discount
                current_from_quantity = viewing_from_quantity
            elif viewing_discount <= highest_product_discount_value:
                if current_discount == highest_product_discount_value:
                    continue
                else:
                    final_discount = final_discount + [tuple([current_from_quantity,current_discount])]
                    current_discount = highest_product_discount_value
                    current_from_quantity = viewing_from_quantity
        i=i+1
    final_discount = final_discount + [tuple([current_from_quantity,current_discount])]

print(display_style)
print(final_discount)







    
    

    

    






    



