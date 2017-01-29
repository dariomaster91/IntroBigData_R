# Input file initialization
#input <- "/home/hduser/Desktop/R/esempio.txt"
imput <- file.choose(new = FALSE)

# Get max columns number and create the table
no_col=max(count.fields(input, sep = ","))
data <- read.table(input, na.strings=c("", "NA"), sep = ",", fill = TRUE, col.names = 1:no_col)

# obtain data frame from the table
df <- as.data.frame(data)

###########################################
# Get all unique combinations of products #
###########################################

# Get list with all unique products
products <- as.vector.factor(unique(df$X2))

# Get all combinations of products
couples <- merge(products, products, all=FALSE)

# Remove combinations with duplicated values
couples <- couples[couples$x != couples$y,]

# Remove repeated permutations
couples.sort <- t(apply(couples, 1, sort))
couples <- couples[!duplicated(couples.sort),]

################################################
# Compare products couples with the data frame #
################################################

library(sqldf)

# Get columns names to use them in SQL query
cols <- paste(colnames(df), collapse = ", ")

# Execute query
results1 <- NULL
results2 <- NULL

for (i in 1:nrow(couples)){
  
  # Get total rows containing each products couple 
  result1 <- sqldf(sprintf("SELECT COUNT(*) as 'COUNT' FROM df WHERE '%s' in (%s) AND '%s' in (%s)", couples[i,1], cols, couples[i,2], cols))
  results1 <- rbind(results1, result1)
  
  # Get number of rows containing product 1 
  result2 <- sqldf(sprintf("SELECT COUNT(*) as 'P1_COUNT' FROM df WHERE '%s' in (%s)", couples[i,1], cols))
  results2 <- rbind(results2, result2)
}

# Get percentage of bills in which the couple of products are present and support of p1->p2
result <- cbind(couples, PERCENT = round(results1$COUNT / nrow(df) * 100, digits = 2), SUPPORT = round(results1$COUNT / results2$P1_COUNT * 100, digits = 2))

# Write results into a destination file
write.table(result, "/home/hduser/Desktop/R/result3.txt", sep=",", col.names = FALSE, row.names = FALSE)
