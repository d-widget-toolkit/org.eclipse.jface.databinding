/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 208858
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.SWTObservableList;

import java.lang.all;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.eclipse.core.databinding.BindingException;
import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.AbstractObservableList;

/**
 * Abstract base class of CComboObservableList, ComboObservableList, and
 * ListObservableList.
 * 
 * @since 3.2
 * 
 */
public abstract class SWTObservableList : AbstractObservableList {

    /**
     * 
     */
    public this() {
        super();
    }

    /**
     * @param realm
     */
    public this(Realm realm) {
        super(realm);
    }

    public void add(int index, Object element) {
        int size = doGetSize();
        if (index < 0 || index > size)
            index = size;
        String[] newItems = new String[size + 1];
        System.arraycopy(getItems(), 0, newItems, 0, index);
        newItems[index] = stringcast( element);
        System.arraycopy(getItems(), index, newItems, index + 1, size - index);
        setItems(newItems);
        fireListChange(Diffs.createListDiff(Diffs.createListDiffEntry(index,
                true, element)));
    }

    public int doGetSize() {
        return getItemCount();
    }

    public Object get(int index) {
        getterCalled();
        return stringcast(getItem(index));
    }

    public Object getElementType() {
        return Class.fromType!(String);
    }

    /**
     * @param index
     * @return the item at the given index
     */
    protected abstract String getItem(int index);

    /**
     * @return the item count
     */
    protected abstract int getItemCount();

    /**
     * @return the items
     */
    protected abstract String[] getItems();

    private void getterCalled() {
        ObservableTracker.getterCalled(this);
    }

    public Object remove(int index) {
        getterCalled();
        int size = doGetSize();
        if (index < 0 || index > size - 1)
            throw new BindingException(
                    "Request to remove an element out of the collection bounds"); //$NON-NLS-1$

        String[] newItems = new String[size - 1];
        String oldElement = getItem(index);
        if (newItems.length > 0) {
            System.arraycopy(getItems(), 0, newItems, 0, index);
            if (size - 1 > index) {
                System.arraycopy(getItems(), index + 1, newItems, index, size
                        - index - 1);
            }
        }
        setItems(newItems);
        fireListChange(Diffs.createListDiff(Diffs.createListDiffEntry(index,
                false, stringcast(oldElement))));
        return stringcast(oldElement);
    }

    public Object set(int index, Object element) {
        String oldElement = getItem(index);
        setItem(index, stringcast( element));
        fireListChange(Diffs.createListDiff(Diffs.createListDiffEntry(index,
                false, stringcast(oldElement)), Diffs.createListDiffEntry(index, true,
                element)));
        return stringcast(oldElement);
    }

    public Object move(int oldIndex, int newIndex) {
        checkRealm();
        if (oldIndex is newIndex)
            return get(oldIndex);
        int size = doGetSize();
        if (oldIndex < 0 || oldIndex >= size)
            throw new IndexOutOfBoundsException(
                    Format("oldIndex: {}, size:{}", oldIndex, size)); //$NON-NLS-1$ //$NON-NLS-2$
        if (newIndex < 0 || newIndex >= size)
            throw new IndexOutOfBoundsException(
                    Format("newIndex: {}, size:{}", newIndex, size)); //$NON-NLS-1$ //$NON-NLS-2$

        String[] items = getItems();
        String[] newItems = new String[size];
        String element = items[oldIndex];
        if (newItems.length > 0) {
            System.arraycopy(items, 0, newItems, 0, size);
            if (oldIndex < newIndex) {
                System.arraycopy(items, oldIndex + 1, newItems, oldIndex,
                        newIndex - oldIndex);
            } else {
                System.arraycopy(items, newIndex, newItems, newIndex + 1,
                        oldIndex - newIndex);
            }
            newItems[newIndex] = element;
        }
        setItems(newItems);
        fireListChange(Diffs.createListDiff(Diffs.createListDiffEntry(oldIndex,
                false, stringcast(element)), Diffs.createListDiffEntry(newIndex, true,
                stringcast(element))));
        return stringcast(element);
    }

    public bool removeAll(Collection c) {
        checkRealm();
        List oldItems = Arrays.asList(getItems());
        List newItems = new ArrayList(oldItems);
        bool removedAll = newItems.removeAll(c);
        if (removedAll) {
            setItems(cast(String[]) newItems.toArray(new String[newItems.size()]));
            fireListChange(Diffs.computeListDiff(oldItems, newItems));
        }
        return removedAll;
    }

    public bool retainAll(Collection c) {
        checkRealm();
        List oldItems = Arrays.asList(getItems());
        List newItems = new ArrayList(oldItems);
        bool retainedAll = newItems.retainAll(c);
        if (retainedAll) {
            setItems(cast(String[]) newItems.toArray(new String[newItems.size()]));
            fireListChange(Diffs.computeListDiff(oldItems, newItems));
        }
        return retainedAll;
    }

    /**
     * @param index
     * @param string
     */
    protected abstract void setItem(int index, String string);

    /**
     * @param newItems
     */
    protected abstract void setItems(String[] newItems);

}
