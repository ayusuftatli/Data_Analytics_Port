Select *
From PortfolioProjects.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, Convert(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

SELECT *
FROM NashvilleHousing

-- Above doesn't work. Tried two times on two different computers. Sorry Alex

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

select *
from NashvilleHousing

-- Populate Property Address Date

Select count(*)
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null

-- There are 29 rows where property address is null

Select *
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-- ParcelID is the same for certain addresses but uniqueID is unique to each entry. 
-- We can find and match the address through ParcelID and then populate

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- it is empty so it worked!

-- Breaking out Addres into individual columns (address, city, state)

select PropertyAddress
FROM NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address, CHARINDEX(',', PropertyAddress)
from NashvilleHousing

-- charindex gives us the position of the comma. So it is a number. So if we add "-1" we can remove the comma from the result

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
from NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	, substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
from NashvilleHousing

-- owner address by using "parsename"

select OwnerAddress
from NashvilleHousing

select 
parsename(OwnerAddress, 1)
from NashvilleHousing

-- nothing happens becuase "parsename" is looking for commas. But we can replace it with period

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
	, parsename(replace(OwnerAddress, ',', '.'), 2)
		, parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing

-- this can be done in a more compact manner

-- Change Y and N to Yes and No in "Sold as Vacant" field becuase it is messed up

SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2 desc


select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2 desc

-- Remove Duplicates (it is not standard to delete the data in the database you are in)
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
Select *
from RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Now delete duplicated

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
from RowNumCTE
WHERE row_num > 1

-- delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate