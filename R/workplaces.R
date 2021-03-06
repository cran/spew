#' Assign an ESRI workplace to synthetic population
#'
#' We look at the ESR variable from the synthetic people, which is the employment status recode.  If values 1, 2, 4, and 5 are considered employed.  We then randomly assign the person inside the county, with weights based on numbers of workers at the place.  We return the ESRI ID of the workplace  Note that in this way, workers do not cross borders.
#' @param people data frame of synthetic people produced by SPEW
#' @param workplaces data frame of workplaces from ESRI
#' 
#' @export
#' 
#' @return column of workplace IDs for synthetic people
assign_workplaces <- function(people, workplaces){
  #TODO:  make it so workers can leave county.  look at county dists.
  impt_vars <- c("ESR", "place_id")
  people <- people[, impt_vars]
  
  # Verify the ESR value is a number
  people$ESR <- as.numeric(as.character(people$ESR))
  
  # Extract the state and county number
  people$co <- substr(people$place_id, 3, 5)
  people$st <- substr(people$place_id, 1, 2)
  
  # Create new employment variable
  people$emp <- ifelse(people$ESR %in% c(1, 2, 4, 5), 1, 0)
  
  # Assign the people to workplaces, as necessary. Note that to run ddply, 
  # we need to have the data-frame ordered. To solve this, we preserve 
  # the original ordering and return the assigned ID's in this order.  
  people_ord <- with(people, order(emp, co))
  original_order <- order(people_ord)
  people <- people[people_ord, ]
  
  work_assignments <- plyr::ddply(people, .variables = c('emp', 'co'), 
                                  .fun = assign_workplaces_inner, 
                                  workplaces = workplaces)
  work_ids <- work_assignments$ids[original_order]
  return(work_ids)
}

#' Function which assigns workplaces
#'
#' @param df subset of people with emp either 0 or 1 and the county number
#' @param workplaces dataframe or ESRI schools
#' @return ID of ESRI workplace or NA
assign_workplaces_inner <- function(df, workplaces) {
if (df$emp[1] == 0) {
    # If the person is not employed, no workplace ID is returned
    ids <- rep(NA, nrow(df))
  } else {    
    # We then subset the workplaces to the county of the people
    stno <- df$st[1]
    cono <- df$co[1]
    workplaces$st <- substr(workplaces$stcotr, 1, 2) # Extract the state number
    workplaces$co <- substr(workplaces$stcotr, 3, 5) # Extract the co. number
    
    # Lee: Removing NA's from workplaces$employees as this also shows 
    # up in the Kansas file
    missing_employees <- which(is.na(workplaces$employees))
    if (length(missing_employees) > 0) {
      workplaces <- workplaces[-missing_employees, ]      
    }
    
    # Lee: This doesn't work (not sure why). Found this error while running 
    # kansas and there was no workplaces for the particular country 
    county_indices <- which(workplaces$co == cono)
    workplaces_sub <- workplaces[county_indices, ]
  
    # If not, then use any workplace in the state
    if (nrow(workplaces_sub) == 0) {
      state_indices <- which(workplaces$st == stno)
      workplaces_sub <- workplaces[state_indices, ] 
    }
    stopifnot(nrow(workplaces_sub) > 0)
    
    # Lee: Needed to add na.rm = TRUE to the sum function here... let's 
    # try to check these things before committing. That way we know the 
    # code can handle off of the conditons it's testing for 
    probs <- workplaces_sub$employees / sum(workplaces_sub$employees, na.rm = TRUE)
    stopifnot(length(probs) == nrow(workplaces_sub))
    
    id_inds <- sample(1:nrow(workplaces_sub), nrow(df), replace = TRUE, prob = probs)
    ids <- workplaces_sub$workplace_id[id_inds]
    stopifnot( sum(is.na(ids)) == 0)
    }
    
    stopifnot(length(ids) == nrow(df))
    return(data.frame(ids = ids, stringsAsFactors = FALSE))
}
