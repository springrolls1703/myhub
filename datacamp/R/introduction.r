# Load data
data(email50)

# View the structure of the data
str(email50)

# Subset of emails with big numbers: email50_big
email50_big <- email50 %>%
  filter(number == "big")

# Glimpse the subset
glimpse(email50_big)

# Calculate median number of characters: med_num_char
med_num_char <- median(email50$num_char)

# Create num_char_cat variable in email50
email50_fortified <- email50 %>%
  mutate(num_char_cat = ifelse(num_char < med_num_char, "below median", "at or above median"))
  
# Count emails in each category
email50_fortified %>%
  count(num_char_cat)

  # Create number_yn column in email50
email50_fortified <- email50 %>%
  mutate(
    number_yn = case_when(
      # if number is "none", make number_yn "no"
      number == "none" ~ "no", 
      # if number is not "none", make number_yn "yes"
      number != "none" ~ "yes"  
    )
  )
  
# ?case_when

# Visualize the distribution of number_yn
ggplot(email50_fortified, aes(x = number_yn)) +
  geom_bar()

# Load ggplot2
library(ggplot2)

# Scatterplot of exclaim_mess vs. num_char
ggplot(email50, aes(x = num_char, y = exclaim_mess, color = factor(spam))) +
  geom_point()


# Load packages
library(dplyr)

# Count number of male and female applicants admitted
ucb_admit %>%
  count(Gender, Admit)

ucb_admission_counts %>%
  # Group by gender
  group_by(Gender) %>%
  # Create new variable
  mutate(prop = n / sum(n)) %>%
  # Filter for admitted
  filter(Admit == "Admitted")


ucb_admission_counts  %>%
  # Group by department, then gender
  group_by(Dept, Gender) %>%
  # Create new variable
  mutate(prop = n / sum(n)) %>%
  # Filter for male and admitted
  filter(Gender == "Male", Admit == "Admitted")

  # Simple random sample: states_srs
states_srs <- us_regions %>%
  sample_n(size = 8 )

# Count states by region
states_srs %>%
  count(region)

each stratum (i.e. Region) is represented equally.
stratifed sample guarantees a number of sample from a group

# Stratified sample
states_str <- us_regions %>%
  group_by(region) %>%
  sample_n(size = 2)

# Count states by region
states_str %>%
  count(region)
  
# Recode cls_students as cls_type
evals_fortified <- evals %>%
  mutate(
    cls_type = case_when(
      cls_students <= 18 ~ "small",
      cls_students > 18 & cls_students <= 59 ~ "midsize",
      cls_students > 59 ~ "large"
    )
  )
  
