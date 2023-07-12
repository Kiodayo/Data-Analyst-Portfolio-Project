--Cleaning Data

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted,CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address data
SELECT *
FROM PortfolioProject..NashvilleHousing
-- PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking out Address into Individual Columns (Address,City,State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing 

--Another way to import city and address
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing
--parse name

SELECT 
PARSENAME(REPlACE(OwnerAddress,',','.'),3),
PARSENAME(REPlACE(OwnerAddress,',','.'),2),
PARSENAME(REPlACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPlACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPlACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPlACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in "Sold as vacant" field
SELECT Distinct(SoldAsVacant),count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

--Remove Duplicates
--CTE
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UNIQUEID
				)ROW_NUM
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

--Deleted Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
