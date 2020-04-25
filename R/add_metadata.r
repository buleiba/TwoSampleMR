#' Add meta data to extracted data
#'
#' Previously the meta data was returned alongside association information. This is mostly unnecessary as it is needlessly repeating information. This is a convenience function that reinstates that information.
#' Can be applied to either exposure data, outcome data, or harmonised data
#'
#' @param dat Either exposure data, outcome data or harmonised data
#' @param cols Which metadata fields to add. Default = c("sample_size", "ncase", "ncontrol", "unit", "sd")
#'
#' @export
#' @return Data frame
add_metadata <- function(dat, cols = c("sample_size", "ncase", "ncontrol", "unit", "sd"))
{
	stopifnot(is.data.frame(dat))
	stopifnot("id.exposure" %in% names(dat) | "id.outcome" %in% names(dat))
	get_info <- function(id, what="exposure", cols)
	{
		info <- ieugwasr::gwasinfo(id)
		if(nrow(info) == 0)
		{
			message(what, ": none of the IDs found in database")
			return(NULL)
		}

		for(col in cols)
		{
			if(!col %in% names(info))
			{
				info[[col]] <- NA
			}
		}

		info <- dplyr::select(info, "id", "sample_size", "ncase", "ncontrol", "unit", "sd")
		names(info) <- paste0(names(info), ".", what)		
		return(info)
	}

	order_col <- random_string()
	dat[[order_col]] <- 1:nrow(dat)
	if("id.exposure" %in% names(dat))
	{
		exposure_id <- unique(dat[["id.exposure"]])
		info <- get_info(id=exposure_id, what="exposure", cols=cols)
		if(!is.null(info))
		{
			dat <- merge(dat, info, by="id.exposure", all.x=TRUE)
		}
	}

	if("id.outcome" %in% names(dat))
	{
		outcome_id <- unique(dat[["id.outcome"]])
		info <- get_info(id=outcome_id, what="outcome", cols=cols)
		if(!is.null(info))
		{
			dat <- merge(dat, info, by="id.outcome", all.x=TRUE)
		}
	}

	names(dat)[names(dat) == "unit.exposure"] <- "units.exposure"
	names(dat)[names(dat) == "unit.outcome"] <- "units.outcome"

	dat <- dat[dat[[order_col]], ]
	dat <- dat[, !names(dat) %in% order_col]
	return(dat)
}
