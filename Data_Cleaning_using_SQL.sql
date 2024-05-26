--Cleaning data using SQL 

SELECT top 10 *
  FROM [Portfolio].[dbo].[Nashville]


--Correcting data format
use Portfolio;
select SaleDate, convert(date,SaleDate) as SaleDate_formatted from Nashville;

update Nashville 
set SaleDate = convert(date, SaleDate);

select top 10 * from Nashville;


--------------------------------------------
/*Property Address cannot be null but if you check the data we can populate the nulls keeping parcelid as reference 
--Row 159 and 160 has the same parcel id but Property Address for row 160 is null so I can populate that null with the address in 159 
 as they share the same parcel id */

select * from Nashville;

select 
UniqueID,
ParcelID,
PropertyAddress
from Nashville
order by ParcelID;

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress from Nashville a join Nashville b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID where a.PropertyAddress is null;

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville a join Nashville b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID where a.PropertyAddress is null;

select * from Nashville where PropertyAddress is null;
----------------------------------------------------------------------------------------
select * from Nashville;

--Breaking Property Address into Street, City

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))
from Nashville;

alter table Nashville
add Street nvarchar(255);

update Nashville
set Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table Nashville
add City nvarchar(255);

update Nashville
set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress));


---Ower Address --> Owner Street Address and Owner State Address

--parsename looks for periods so i can replace , in Owner Address and replace it with period which parsename is going to split 
select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as OStreet,
PARSENAME(Replace(OwnerAddress,',','.'),2) as OCity,
PARSENAME(Replace(OwnerAddress,',','.'),1) as OState
from Nashville;


Alter table Nashville
add Owner_Street_Address varchar(255), Owner_City varchar(255), Owner_State varchar(255);

Update Nashville
set Owner_Street_Address = PARSENAME(Replace(OwnerAddress,',','.'),3) 

Update Nashville
set Owner_City = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Update Nashville
set Owner_State = PARSENAME(Replace(OwnerAddress,',','.'),1) 

select * from Nashville;
-----------------------------------------------------------------------

select distinct(SoldAsVacant) from Nashville;

--Change Y and N to Yes and No in Sold As Vacant 

select case
when SoldAsVacant = 'No' then 'N'
When SoldAsVacant = 'Y' then 'Yes'
Else SoldAsVacant 
end
 as SoldAsVacant
from Nashville;

Update Nashville 
SET SoldAsVacant = 
Case 
When SoldAsVacant = 'N' then 'No'
When SoldAsVacant = 'Y' then 'Yes'
Else SoldAsVacant 
end

select distinct(SoldAsVacant) from Nashville;

------------------------------------------------------------------------------
--Remove Duplicates 

with rowcntnum as (
select * , ROW_NUMBER() over ( Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueId) row_num from Nashville  
)
delete from rowcntnum where row_num >1;

with rowcntnum as (
select * , ROW_NUMBER() over ( Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueId) row_num from Nashville  
)
select * from rowcntnum where row_num >1;

