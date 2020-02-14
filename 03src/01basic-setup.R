getwd()

# 사용하고자 하는 패키지를 벡터로 저장
pkg = c("tidyverse", "skimr", "GGally", "plotly", "viridis", "caret", "randomForest", "e1071",
        "rpart", "xgboost", "h2o", "corrplot", "knitr", "rattle",
        "rpart.plot", "corrgram", "visNetwork","sparkline",
        "mlbench")


# 기존에 설치 되어있는 패키지를 제외하고 설치하고 알아서 로드한다. 
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

# 함수호출
ipak(pkg)



#library(doParallel)
#cores <- 7
#registerDoParallel(cores = cores)