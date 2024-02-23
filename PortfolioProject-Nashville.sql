select * from PortfolioProjects.dbo.nashville

--Standardize Date Format

select SaleDate, CONVERT (Date,SaleDate)
from PortfolioProjects.dbo.nashville

update PortfolioProjects.dbo.nashville
SET SaleDate = CONVERT(Date, SaleDate)

--Populate Property Address
select PropertyAddress
from PortfolioProjects.dbo.nashville
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.dbo.nashville a
JOIN PortfolioProjects.dbo.nashville b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--To  update the propertyAddress showing null

update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.dbo.nashville a
JOIN PortfolioProjects.dbo.nashville b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------
-- Breaking out Property Address Into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProjects.dbo.nashville


Select SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address ,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) ) as Address 
from PortfolioProjects.dbo.nashville

-- To add new address column to the table

ALTER TABLE PortfolioProjects.dbo.nashville
ADD PropertySplitAddress Nvarchar(255)

Update PortfolioProjects.dbo.nashville
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProjects.dbo.nashville
ADD PropertySplitCity Nvarchar(255)

Update PortfolioProjects.dbo.nashville
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) )


-----------------------------------------------------------------------------------------------------------------
-- Breaking out Owner Address Into Individual Columns (Address, City, State) using ParseName

select OwnerAddress, UniqueID from PortfolioProjects.dbo.nashville
---where OwnerAddress is null

select PARSENAME (REPLACE(OwnerAddress,',','.'), 3) Address,
	PARSENAME (REPLACE(OwnerAddress,',','.'), 2) State,
	PARSENAME (REPLACE(OwnerAddress,',','.'), 1) City
from PortfolioProjects.dbo.nashville

ALTER TABLE PortfolioProjects.dbo.nashville
ADD OwnerSplitAddress Nvarchar(255)

Update PortfolioProjects.dbo.nashville
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProjects.dbo.nashville
ADD OwnerSplitCity Nvarchar(255)

Update PortfolioProjects.dbo.nashville
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProjects.dbo.nashville
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProjects.dbo.nashville
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)


---------- Change 1 to Yes and 0 to No in SoldAsVacant column

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.nashville
GROUP BY SoldAsVacant
order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = '1' then 'YES'
When SoldAsVacant = '0' then 'No'
END
from PortfolioProjects.dbo.nashville 

---To update the SoldAsVacant column
Update PortfolioProjects.dbo.nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' then 'YES'
When SoldAsVacant = '0' then 'No'
END

----This comes before the update to convert the SoldAsVacant datatype to VARCHAR (This could lead to data Loss)
ALTER TABLE PortfolioProjects.dbo.nashville
ALTER COLUMN SoldAsVacant VARCHAR(50);
--------------------------------------------

------Removing duplicates...

select * from PortfolioProjects.dbo.nashville

with RowNumCTE AS (
Select * , 
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
from PortfolioProjects.dbo.nashville 
)
---To delete duplicate that is where row_num is 2
---DELETE from RowNumCTE
---Where row_num > 1

SELECT * from RowNumCTE
Where row_num > 1

------------------------------------------------------------
----To DELETE/DROP COLUMNS FROM THE TABLE

select * from PortfolioProjects.dbo.nashville

ALTER TABLE PortfolioProjects.dbo.nashville
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant








