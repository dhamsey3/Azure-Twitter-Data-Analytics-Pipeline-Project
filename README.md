# Azure-Twitter-Data-Analytics-Pipeline-Project
This project builds a robust data pipeline for real-time Twitter data analysis using Snowflake and Azure services. The pipeline captures Twitter data, stores it in Azure, and utilizes Snowflake for processing and analysis, culminating in insightful dashboards.


# Twitter Data Analytics Pipeline Project

## Overview
This project develops a data pipeline to ingest real-time Twitter data, store it in Azure, and analyze it using Snowflake. The focus is on utilizing Azure for all data handling tasks and Snowflake for sophisticated data querying and dashboard visualizations.

## Prerequisites
- **Snowflake Account**: Required for data warehousing and analytics.
- **Azure Account**: Necessary for utilizing Azure cloud services.
- **Twitter Developer Account**: Needed to fetch Twitter data via Twitter APIs.

## Setup Instructions

### 1. Snowflake Configuration

#### a. Create Snowflake Account
- Sign up or log in at [Snowflake](https://snowflake.com/).
- Configure your instance for data warehousing.

#### b. Set Up Snowflake for Data Storage
- Define warehouses, databases, and schemas suitable for storing Twitter data.

### 2. Twitter API Setup

#### a. Register Twitter Developer Account
- Navigate to [Twitter Developers](https://developer.twitter.com/en/apply-for-access) and secure your API credentials: API key, API secret key, and Bearer token.

### 3. Azure Configuration

#### a. Create Azure Storage Account
```shell
az login
az account set --subscription "Your Subscription Name"
az storage account create --name <storage_account_name> --resource-group <resource_group_name> --location <location> --sku Standard_RAGRS --kind StorageV2
