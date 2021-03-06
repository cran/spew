context("Workplace Functions")

test_that("United States Workplace Assignment", {
  
  # Get the data for a randomly sampled tract set up ------------------------
  data(delaware)
  index <- 17
  
  # Obtain the specific parameters for this run of make 
  n_house <- delaware$pop_table[index, "n_house"]
  puma_id <- delaware$pop_table[index, "puma_id"]
  place_id <- delaware$pop_table[index, "place_id"]
  
  # Sample n indices from the household pums 
  sampled_households <- sample_households(method = "uniform",
                                          n_house = n_house, 
                                          pums_h = delaware$pums$pums_h, 
                                          pums_p = delaware$pums$pums_p, 
                                          puma_id = puma_id, 
                                          place_id = place_id)
  
  # Attach locations to the sample households 
  locations <- sample_locations(method = "uniform", place_id = place_id, n_house = n_house, 
                                shapefile = delaware$shapefile$shapefile)
  sampled_households$longitude <- locations@coords[, 1]
  sampled_households$latitude <- locations@coords[, 2]
  
  # Add a synthetic serial ID and place ID 
  # to the sampled households 
  sampled_households$SYNTHETIC_SERIAL <- 1:nrow(sampled_households)
  stopifnot(!any(duplicated(sampled_households$SYNTHETIC_SERIAL)))
  
  sampled_households$place_id <- place_id
  sampled_households$puma_id <- puma_id
  
  # Attach people to the sampled households and make 
  # sure to include both the place and puma id
  sampled_people <- sample_people(method = "uniform", 
                                  household_pums = sampled_households, 
                                  pums_p = delaware$pums$pums_p, 
                                  puma_id = puma_id, 
                                  place_id = place_id)  
  
  sampled_people$place_id <- place_id
  sampled_people$puma_id <- puma_id
  sampled_people$st <- substr(place_id, 1, 2)
  sampled_people$co <- substr(place_id, 3, 5)
  sampled_people$ESR <- as.numeric(as.character(sampled_people$ESR))
  sampled_people$emp <- ifelse(sampled_people$ESR %in% c(1,2,4,5), 1,0)
  
  # Workplaces --------------------------------------
  library(plyr)
  
  # Set up workplace assignment data-frame 
  workplace_ids <- assign_workplaces(sampled_people, delaware$workplaces)

  work_df <- data.frame(emp = sampled_people$emp,
                        work = workplace_ids,
                        st = sampled_people$st,
                        co = sampled_people$co)
                      

  # Make sure all of the employed people are assigned to a workplace
  worker_inds <- which(work_df$emp == 1)
  expect_equal(any(is.na(work_df$work[worker_inds])), FALSE)

  # make sure all the workplaces assigned are from the proper subset
  workplaces <- delaware$workplaces
  workplaces$st <- substr(workplaces$stcotr, 1, 2)
  workplaces$co <- substr(workplaces$stcotr, 3, 5)
  stno <- sampled_people$st[1]
  cono <- sampled_people$co[1]
  workplace_sub <- subset(workplaces, (st == stno & co == cono))
  expect_equal(all(sampled_people$work %in% workplace_sub$workplace_id), TRUE)
})

