module Hkl.H5
    ( Dataset
    , File
    , check_ndims
    , closeDataset
    , get_position
    , get_ub
    , lenH5Dataspace
    , openDataset
    , withH5File
    )
    where


import Bindings.HDF5.Core ( HSize(..) )
import Bindings.HDF5.File ( File
                          , AccFlags(ReadOnly)
                          , openFile
                          , closeFile
                          )
import Bindings.HDF5.Dataset ( Dataset
                             , openDataset
                             , closeDataset
                             , getDatasetSpace
                             , readDataset
                             , readDatasetInto
                             )
import Bindings.HDF5.Dataspace ( Dataspace
                               , SelectionOperator(Set)
                               , closeDataspace
                               , createSimpleDataspace
                               , getSimpleDataspaceExtentNDims
                               , getSimpleDataspaceExtentNPoints
                               , selectHyperslab
                               )

import Control.Exception (bracket)
import Data.ByteString.Char8 (pack)
import Data.Vector.Storable (Vector, freeze)
import Data.Vector.Storable.Mutable (replicate)
import Foreign.C.Types (CInt(..))
import Numeric.LinearAlgebra (Matrix, reshape)
import Prelude hiding (replicate)

{-# ANN module "HLint: ignore Use camelCase" #-}

check_ndims :: Dataset -> Int -> IO Bool
check_ndims d expected = do
  space_id <- getDatasetSpace d
  (CInt ndims) <- getSimpleDataspaceExtentNDims space_id
  return $ expected == fromEnum ndims

get_position :: Dataset -> Int -> IO (Vector Double)
get_position dataset n =
    withDataspace dataset $ \dataspace -> do
      let start = HSize (fromIntegral n)
      let stride = Just (HSize 1)
      let count = HSize 1
      let block = Just (HSize 1)
      selectHyperslab dataspace Set [(start, stride, count, block)]
      withDataspace' $ \memspace -> do
        data_out <- replicate 1 (0.0 :: Double)
        readDatasetInto dataset (Just memspace) (Just dataspace) Nothing data_out
        freeze data_out

get_ub :: Dataset -> IO (Matrix Double)
get_ub dataset = do
  v <- readDataset dataset Nothing Nothing
  return $ reshape 3 v

-- | File

withH5File :: FilePath -> (File -> IO r) -> IO r
withH5File fp = bracket acquire release
    where
      acquire = openFile (pack fp) [ReadOnly] Nothing
      release = closeFile

-- | Dataspace

-- check how to merge both methods

withDataspace' :: (Dataspace -> IO r) -> IO r
withDataspace' = bracket acquire release
  where
    acquire = createSimpleDataspace [HSize 1]
    release = closeDataspace

withDataspace :: Dataset -> (Dataspace -> IO r) -> IO r
withDataspace d = bracket acquire release
  where
    acquire = getDatasetSpace d
    release = closeDataspace

lenH5Dataspace :: Dataset -> IO (Maybe Int)
lenH5Dataspace = withDataspace'' len
  where
    withDataspace'' f d = withDataspace d f
    len space_id = do
      (HSize n) <- getSimpleDataspaceExtentNPoints space_id
      return $ if n < 0 then Nothing else Just (fromIntegral n)
