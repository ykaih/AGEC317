# Load package
library(dplyr)
library(reshape2) # melt
library(data.table) # fread

# Clean data in the global environment
rm(list = ls())

# 1. Load data ------------------------------------------------------------------------------------------
# The original data is from https://www.kaggle.com/c/instacart-market-basket-analysis
DF_products <- fread("products.csv")
DF_orders <- fread("orders.csv")
DF_aisles <- fread("aisles.csv")
DF_departments <- fread("departments.csv")
DF_order_products_prior <- fread("order_products__prior.csv")
DF_order_products_train <- fread("order_products__train.csv")

# Merge data
DF_order_list <- merge(DF_orders, DF_order_products_train, by="order_id")
DF_order_list <- merge(DF_order_list, DF_products, by="product_id")
DF_order_list <- merge(DF_order_list, DF_aisles, by="aisle_id")
DF_order_list <- merge(DF_order_list, DF_departments, by="department_id")

# Sort the data
DF_order_list <- DF_order_list[order(DF_order_list$user_id, DF_order_list$order_id),]

# For demo (Multiple regression) ------------------------------------------------------------------------------------------
# Randomly select users
set.seed(20200903)
Selected_500users <- sample(unique(DF_order_list$user_id), size = 500, replace=F)

# Extract the smaller samples (1,384,617 obs >> 5,321 obs)
DF_500users_train <- DF_order_list %>% filter(user_id %in% Selected_500users)
DF_500users_train <- DF_500users_train[order(DF_500users_train$user_id, DF_500users_train$order_id),]

DF_reordered_500users_train <- DF_500users_train %>% 
  group_by(order_id) %>% 
  summarize(reorders = sum(reordered), products = n_distinct(product_id), 
            days_since_prior_order = min(days_since_prior_order))

# Save as a CSV file
write.csv(DF_500users_train, "Random_500users_train.csv")
