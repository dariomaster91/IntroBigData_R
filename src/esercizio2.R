# Input file initialization
#input <- "/home/hduser/Desktop/R/data/esempio.txt"
#prices <- "/home/hduser/Desktop/R/data/prices.csv"

input <- file.choose(new = FALSE)
prices <- file.choose(new = FALSE)

# Get max columns number and create the table
no_col=max(count.fields(input, sep = ","))
data <- read.table(input, na.strings=c("", "NA"), sep = ",", fill = TRUE, col.names = 1:no_col)

# Extract year-month values
data$X1 <- substr(data$X1, 1, 7)

# Split rows in order to obtain a dataset with a date for each product purchesed
library(reshape2)
melteddata <- melt(data, id = "X1")

# obtain data frame from the table
df <- as.data.frame(melteddata)

# remove rows having NA values
df <- df[complete.cases(df),]

# assign the value one to each row in the dataframe
df["sum"] <- 1
names(df) <- c("date", "variable", "products", "sum")

# remove useless column df$variable
df$variable <- NULL

# Use plyr library to perform a count with group-by date
library(plyr)
df <- count(df, c("date", "products"))

# Sort dataframe by month and freq decreasing
df <- df[order(df$date, -df$freq),]

# Load price list file
price_list <- read.csv(prices, header = FALSE, sep = ",")
names(price_list) <- c("products", "price")

# Perform a left outer join between df and price_list
df <- merge(x = df, y = price_list, by = "products", all.x = TRUE)

# Sort dataframe by product and month
df <- df[order(df$products, df$date),]

# Calculate profit
df["profit"] <- df$freq * df$price

# Change date format
library(stringr)
df_date <- as.data.frame(str_split_fixed(df$date, "-", 2))
df_date <- within(df_date, date <- paste(df_date$V2, df_date$V1, sep='/'))
df$date <- df_date$date

# Paste columns date and profit to get unique value column (date_profit)
df <- within(df, date_profit <- paste(date, profit, sep=':'))

# Aggregate data as per exercise text
result <- aggregate(date_profit ~ products, data = df, c )

# Write results into a destination file
write.table(result, "/home/hduser/Desktop/R/output/result2.txt", sep=" ", col.names = FALSE, row.names = FALSE)
