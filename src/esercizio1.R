# Input file initialization
#input <- "/home/hduser/Desktop/R/data/esempio.txt"
input <- file.choose(new = FALSE)

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

# Get the first 5 products for each month
df <- ddply(df, "date", function(x) head(x, n=5))

# Paste columns product and freq to get unique value column (products_freq)
df <- within(df, products_freq <- paste(products, freq, sep=' '))

# Aggregate data as per exercise text
result <- aggregate(products_freq ~ date, data = df, c )
#df$date <- paste(df$date, ":", sep="")

# Write results into a destination file
write.table(result, "/home/hduser/Desktop/R/output/result1.txt", sep=",", col.names = FALSE, row.names = FALSE)