# Load package
library(dplyr)
library(reshape2) # melt
library(knitr)  # kable
library(data.table) # fread
library(fastDummies)

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
DF_order_list <- merge(DF_orders, DF_order_products_prior, by="order_id")
DF_order_list <- merge(DF_order_list, DF_products, by="product_id")
DF_order_list <- merge(DF_order_list, DF_aisles, by="aisle_id")
DF_order_list <- merge(DF_order_list, DF_departments, by="department_id")

# Sort the data
DF_order_list <- DF_order_list[order(DF_order_list$user_id, DF_order_list$order_id),]

# For demo (Multiple regression) ------------------------------------------------------------------------------------------
# Randomly select users
set.seed(20200930)
Selected_Users_50users <- sample(unique(DF_order_list$user_id), size = 50, replace=F)

# Extract the smaller samples 
DF_50users <- DF_order_list %>% filter(user_id %in% Selected_Users_50users)
DF_50users <- DF_50users[order(DF_50users$user_id, DF_50users$order_id),]

# Group by to the order level
DF_50users_order <- DF_50users %>% 
  select(order_id,product_id,reordered,order_dow,order_hour_of_day,days_since_prior_order) %>%
  group_by(order_id) %>% 
  summarize(reorders = sum(reordered), 
            products = n_distinct(product_id), 
            order_dow = first(order_dow),
            order_hour_of_day = first(order_hour_of_day),
            days_since_prior_order = first(days_since_prior_order))

# Create day dummies
DF_dow_dummy <- dummy_columns(factor(DF_50users_order$order_dow, levels = c(1:6,0)))

# Rename
colnames(DF_dow_dummy) <- c("order_dow","Mon","Tue","Wed","Thu","Fri","Sat","Sun")

# Merge the groupby data set with the dummy data set
DF_50users_order <- cbind.data.frame(DF_50users_order, DF_dow_dummy)

# Rearrange column orders
DF_50users_order <- DF_50users_order[,c("order_id","reorders","products","order_hour_of_day","days_since_prior_order",
                                        "order_dow","Mon","Tue","Wed","Thu","Fri","Sat","Sun")]

# Save as a CSV file
write.csv(DF_50users, "Random_50users.csv")
write.csv(DF_50users_order, "Random_50users_order.csv")