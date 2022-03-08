/*

Cleaning Data in SQL Queries
Data Cleaning Portfolio

*/

--Display all the table/Base data
select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------
--Standardize Date Format
Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

---------------------------------------------------------------------------------------------------------------
--Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

  --Eliminate Nulls
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null
  --Update Table
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--To evaluate the changes
Select *
From PortfolioProject.dbo.NashvilleHousing

-----Fixing Owner Address
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--To evaluate the changes
Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant 
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

-- Data Replacement
Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
                                PropertyAddress, 
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
								) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

--Evaluate changes
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
                                PropertyAddress, 
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID
								) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

--First Group Deleted
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--Second Group Deleted
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

---------------------------------------------------------------------------------------------------------------