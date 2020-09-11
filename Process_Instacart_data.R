# Load package
library(dplyr)

# Clean data in the global environment
rm(list = ls())

# 1. Load data ------------------------------------------------------------------------------------------
# The following original data is from https://www.kaggle.com/c/instacart-market-basket-analysis
DF_products <- read.csv("products.csv")
DF_orders <- read.csv("orders.csv")
DF_aisles <- read.csv("aisles.csv")
DF_departments <- read.csv("departments.csv")
DF_order_products_prior <- read.csv("order_products__prior.csv")
DF_order_products_train <- read.csv("order_products__train.csv")

# Merge data
DF_order_list <- merge(DF_orders, DF_order_products_train, by="order_id")
DF_order_list <- merge(DF_order_list, DF_products, by="product_id")
DF_order_list <- merge(DF_order_list, DF_aisles, by="aisle_id")
DF_order_list <- merge(DF_order_list, DF_departments, by="department_id")

# Sort the data
DF_order_list <- DF_order_list[order(DF_order_list$user_id, DF_order_list$order_id),]

# Check the number of unique orders and users
n_distinct(DF_order_list$order_id)
n_distinct(DF_order_list$user_id)

# For demo (Simple linear regression) ------------------------------------------------------------------------------------------
# Randomly select users
set.seed(20200903)
Selected_Users_demo <- sample(unique(DF_order_list$user_id), size = 5000, replace=F)

# Extract the smaller samples (1,384,617 obs >> 2,736 obs)
DF_demo_small <- DF_order_list %>% filter(user_id %in% Selected_Users_demo)
DF_demo_small <- DF_demo_small[order(DF_demo_small$user_id, DF_demo_small$order_id),]

# Group by at the order-level
DF_reordered_demo <- DF_demo_small %>% 
  group_by(order_id) %>% 
  summarize(count_reorders = sum(reordered), count_products = n_distinct(product_id)) 

# Save as a CSV file
write.csv(DF_reordered_demo, "Instacart_demo.csv")
