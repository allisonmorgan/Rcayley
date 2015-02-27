source("cayley.R")

## more advanced functions which may take work to make more generalizable

# GRAB RELEVANT INFO:
# returns: a table with columns "content" (content id), "id" (topic), and "source" (utm campaign)
GetCampaignTopics <- function(host, port, aid) {
	root <- paste("g.V(\"", aid, "\")", sep = "")
	query <- paste(root, ".Out(\"/aid/content\").As(\"content\").Out(\"/content/utm/campaign\").As(\"source\").Back(\"content\").Out(\"/content/textalytics\").Out(\"/content/textalytics/concept\").All()", sep = "")
	return(Query(host, port, query))
}
#tmp <- GetCampaignTopics("lyd5", "64210", "1327")
#tmp$result[1:20,]

# get campaigns by topic
# returns: list( topic = vector(campaigns, ...), ... )
GetCampaignsByTopic <- function(host, port, aid) {
	campaignsAndTopics <- GetCampaignTopics(host, port, aid)
	campaignsByTopic <- list()
	topics <- unique(campaignsAndTopics$result$id)
	for (i in topics) {
		campaignsByTopicI <- vector()
		for (j in 1:length(campaignsAndTopics$result$id)) {
			if (i == campaignsAndTopics$result$id[[j]]) {
				campaign <- campaignsAndTopics$result$source[[j]]
				if (!(campaign %in% campaignsByTopicI)) {
					campaignsByTopicI <- append(campaignsByTopicI, campaign)
				}
			}
		}
		campaignsByTopic[[i]] <- campaignsByTopicI
	}
	return(campaignsByTopic)
}
bytopic <- GetCampaignsByTopic("lyd5", "64210", "1327")
bytopic$school
bytopic$student
bytopic$exam
bytopic$prize

# get topics by campaign
# returns: list( campaign = vector(topics, ...), ... )
GetTopicsByCampaign <- function(host, port, aid) {
	campaignsAndTopics <- GetCampaignTopics(host, port, aid)
	campaigns <- unique(campaignsAndTopics$result$source)
	topicsByCampaign <- list()
	for (i in campaigns) {
		topicsByCampaignI <- vector()
		for (j in 1:length(campaignsAndTopics$result$source)) {
			if (i == campaignsAndTopics$result$source[[j]]) {
				topic <- campaignsAndTopics$result$id[[j]]
				if (!(topic %in% topicsByCampaignI)) {
					topicsByCampaignI <- append(topicsByCampaignI, topic)
				}
			}
		}
		topicsByCampaign[[i]] <- topicsByCampaignI
	}
	return(topicsByCampaign)
}
bycampaign <- GetTopicsByCampaign("lyd5", "64210", "1327")
bycampaign$ep
bycampaign$unigo_august_2014_HSS
bycampaign$unigo_july_2014_HSS

# CLUSTERING:
# if campaignA and campaignB have at least one topic in common, they are related
# returns: big adjacency matrix
GetCampaignRelationships <- function(host, port, aid) {
	campaignsAndTopics <- GetCampaignTopics(host, port, aid)
	campaigns <- unique(campaignsAndTopics$result$source)

	campaignsByTopic <- GetCampaignsByTopic(host, port, aid)
	# now build square matrix
	adjacency <- matrix(nrow=length(campaigns),ncol=length(campaigns),dimnames=list(campaigns, campaigns))
	# go through each topic
	for (campaignList in campaignsByTopic) {
		# go through each campaign which contains info related to that topic
		# and relate each campaign to each other
		for (i in 1:length(campaignList)) {
			for (j in 1:length(campaignList)) {
				adjacency[[campaignList[[i]], campaignList[[j]]]] <- 1
			}
		}
	}
	# replace NA's with 0's
	adjacency[is.na(adjacency)]<-0
	return(adjacency)
}
w <- GetCampaignRelationships("lyd5", "64210", "1327")
w[(nrow(w)-5):nrow(w), (ncol(w)-5):ncol(w)]
isSymmetric(w)

# contains some data science magic
# reduce adjacency matrix and return significant matrix after SVD
# returns: smaller (not adjacency) matrix
ReduceAdjacencyMatrix <- function(mat) {
	decomp <- svd(mat)
	eigenvalues <- decomp$e
	ratios <- eigenvalues/cumsum(eigenvalues)
	count <- sum(ratios > .05)
	return(decomp$u[, 1:count])
}
adj <- ReduceAdjacencyMatrix(w)

# use kmeans for clustering (say 4)
clustering <- kmeans(adj, 4)
# the vector which maps each campaign to a cluster
assignments <- clustering$cluster
# names of campaigns
campaigns <- rownames(w)

# campaigns and assignments must be vectors of the same length
CampaignsByCluster <- function(campaigns, assignments) {
	campaignsByClusters <- list()
	for (i in unique(assignments)) {
		campaignsByClusterI <- vector()
		for (j in 1:length(assignments)) {
			if (i == assignment[j]) {
				campaignsByClusterI <- append(campaignsByClusterI, campaigns[j])
			}
		}
		campaignsByClusters[[i]] <- unique(campaignsByClusterI)
	}
	return(campaignsByClusters)
}
CampaignsByCluster(campaigns, assignments)

# no data science magic applied here
TopicsByCluster <- function(topicsByCampaign, assignments) {
	campaigns <- names(topicsByCampaign)
	topicsByClusters <- list()
	for (i in unique(assignments)) {
		topicsByClusterI <- vector()
		for (j in 1:length(assignments)) {
			topicVectorJ <- topicsByCampaign[campaigns[j]]
			for (topicJ in topicVectorJ) {
				if (i == assignment[j]) {
					topicsByClusterI <- append(topicsByClusterI, topicJ)
				}
			}
		}
		topicsByClusters[[i]] <- unique(topicsByClusterI)

	}
	return(topicsByClusters)
}
TopicsByCluster(bycampaign, assignments)