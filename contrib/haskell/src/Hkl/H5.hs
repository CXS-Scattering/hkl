module Hkl.H5
    ( check_ndims
    , closeH5Dataset
    , get_position
    , get_position'
    , lenH5Dataspace
    , openH5Dataset
    , withH5File
    )
    where

import Bindings.HDF5.Raw
-- import Control.Applicative
import Control.Exception (bracket)
import Control.Monad (void)
import Foreign.C.String (withCString)
import Foreign.C.Types (CInt(..))
-- import Foreign.Ptr
import Foreign.Ptr.Conventions (withInList, withOutList)

{-# ANN module "HLint: ignore Use camelCase" #-}


-- static herr_t attribute_info(hid_t location_id, const char *attr_name, const H5A_info_t *ainfo, void *op_data)
-- {
-- 	printf("    Attribute: %d %s\n", location_id, attr_name);

-- 	return 0;
-- }

-- static herr_t file_info(hid_t loc_id, const char *name, const H5L_info_t *info, void *opdata)
-- {
-- 	H5O_info_t statbuf;
-- 	hsize_t n = 0;

-- 	/*
-- 	 * Get type of the object and display its name and type.
-- 	 * The name of the object is passed to this function by
-- 	 * the Library. Some magic :-)
-- 	 */
-- 	H5Oget_info_by_name(loc_id, name, &statbuf, H5P_DEFAULT);
-- 	switch (statbuf.type) {
-- 	case H5O_TYPE_UNKNOWN:
-- 		printf(" Object with name %s is an unknown type\n", name);
-- 		break;
-- 	case H5O_TYPE_GROUP:
-- 		printf(" Object with name %s is a group\n", name);
-- 		break;
-- 	case H5O_TYPE_DATASET:
-- 		printf(" Object with name %s is a dataset\n", name);
-- 		break;
-- 	case H5O_TYPE_NAMED_DATATYPE:
-- 		printf(" Object with name %s is a named datatype\n", name);
-- 		break;
-- 	default:
-- 		printf(" Unable to identify an object ");
-- 	}

-- 	H5Aiterate_by_name(loc_id,  name, H5_INDEX_NAME, H5_ITER_NATIVE, &n, attribute_info, NULL, H5P_DEFAULT);

-- 	return 0;
-- }

check_ndims :: HId_t -> Int -> IO Bool
check_ndims hid expected = do
  space_id <- h5d_get_space hid
  (CInt ndims) <- h5s_get_simple_extent_ndims space_id
  return $ expected == fromEnum ndims

-- DataType

withH5DataType :: HId_t -> (Maybe HId_t -> IO r) -> IO r
withH5DataType hid = bracket acquire release
  where
    acquire = do
      type_id@(HId_t status) <- h5d_get_type hid
      return $ if status < 0 then Nothing else Just type_id
    release = maybe (return $ HErr_t (-1)) h5t_close

get_position :: HId_t -> Int -> IO ([Double], HErr_t)
get_position hid n = withH5DataType hid (maybe default_ read''')
  where
    default_ = return ([], HErr_t (-1))
    read''' mem_type_id = withDataspace hid (maybe default_ read'')
      where
        read'' space_id = do
          void $
            withInList [HSize_t (fromIntegral n)] $ \start ->
            withInList [HSize_t 1] $ \stride ->
            withInList [HSize_t 1] $ \count ->
            withInList [HSize_t 1] $ \block ->
            h5s_select_hyperslab space_id h5s_SELECT_SET start stride count block
          withDataspace' (maybe default_ read')
            where
              read' mem_space_id = withOutList 1 $ \rdata ->
                h5d_read hid mem_type_id mem_space_id space_id h5p_DEFAULT rdata

get_position' :: Maybe HId_t -> Int -> IO [Double]
get_position' dataset idx = maybe default_ get_positions'' dataset
  where
    default_ = return [0.0]
    get_positions'' dataset_id = do
      (positions, HErr_t status) <- get_position dataset_id idx
      if status < 0 then do
        (failovers, HErr_t status') <- get_position dataset_id 0
        return $ if status' < 0 then [0.0] else failovers
      else return $ if status < 0 then [0.0] else positions

-- | File

withH5File :: FilePath -> (HId_t -> IO r) -> IO r
withH5File fp f = do
  mhid <- openH5File fp
  maybe (return $ error $ "Can not read the h5 file: " ++ fp) go mhid
    where
      go hid = bracket (return hid) h5f_close f

openH5File :: FilePath -> IO (Maybe HId_t)
openH5File fp = do
  hid@(HId_t status) <- withCString fp (\file -> h5f_open file h5f_ACC_RDONLY h5p_DEFAULT)
  return $ if status < 0 then Nothing else Just hid

-- | Dataset

type DatasetPath = String

openH5Dataset :: HId_t -> DatasetPath -> IO (Maybe HId_t)
openH5Dataset h dp = do
  hid@(HId_t status) <- withCString dp (\dataset -> h5d_open2 h dataset h5p_DEFAULT)
  return $ if status < 0 then Nothing else Just hid

closeH5Dataset :: Maybe HId_t -> IO ()
closeH5Dataset = maybe (return ()) (void . h5d_close)

-- | Dataspace
-- check how to merge both methods

withDataspace' :: (Maybe HId_t -> IO r) -> IO r
withDataspace' = bracket acquire release
  where
    acquire = do
      space_id@(HId_t status) <-
        withInList [HSize_t 1] $ \current_dims ->
        withInList [HSize_t 1] $ \maximum_dims ->
        h5s_create_simple 1 current_dims maximum_dims
      return $ if status < 0 then Nothing else Just space_id
    release = maybe  (return $ HErr_t (-1)) h5s_close

withDataspace :: HId_t -> (Maybe HId_t -> IO r) -> IO r
withDataspace hid = bracket acquire release
  where
    acquire = do
      space_id@(HId_t status) <- h5d_get_space hid
      return  $ if status < 0 then Nothing else Just space_id
    release = maybe (return $ HErr_t (-1)) h5s_close

lenH5Dataspace :: Maybe HId_t -> IO (Maybe Int)
lenH5Dataspace = maybe (return Nothing) (withDataspace'' (maybe (return Nothing) len))
  where
    withDataspace'' f hid = withDataspace hid f
    len space_id = do
      (HSSize_t n) <- h5s_get_simple_extent_npoints space_id
      return $ if n < 0 then Nothing else Just (fromIntegral n)