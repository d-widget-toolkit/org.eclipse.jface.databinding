/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 137877
 *     Brad Reynolds - bug 164653
 *     Brad Reynolds - bug 147515
 *     Ashley Cambrell - bug 198906
 *******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ViewerMultipleSelectionObservableList;
import org.eclipse.jface.internal.databinding.viewers.SelectionProviderMultipleSelectionObservableList;

import java.lang.all;
import java.util.Collection;
import java.util.Iterator;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.jface.databinding.viewers.IViewerObservableList;
import org.eclipse.jface.viewers.Viewer;

/**
 * Observes single selection of a <code>Viewer</code>.
 * 
 * @since 1.2
 */
public class ViewerMultipleSelectionObservableList :
        SelectionProviderMultipleSelectionObservableList ,
        IViewerObservableList {
    public override Object getElementType(){
        return super.getElementType();
    }
    public override bool add(Object o){
        return super.add(o);
    }
    public override bool add(String o){
        return add(stringcast(o));
    }
    public override bool addAll(Collection o){
        return super.addAll(o);
    }
    public override void clear(){
        return super.clear();
    }
    public override bool contains(Object o){
        return super.contains(o);
    }
    public override bool containsAll(Collection o){
        return super.containsAll(o);
    }
    public override int size(){
        return super.size();
    }
    public override bool isEmpty(){
        return super.isEmpty();
    }
    public override hash_t toHash(){
        return super.toHash();
    }
    public override equals_t opEquals(Object o){
        return super.opEquals(o);
    }
    public override bool remove(String o){
        return super.remove(o);
    }
    public override bool remove(Object o){
        return super.remove(o);
    }
    public override Object remove(int o){
        return super.remove(o);
    }
    public override Iterator iterator(){
        return super.iterator();
    }
    public override bool removeAll(Collection o){
        return super.removeAll(o);
    }
    public override bool retainAll(Collection o){
        return super.retainAll(o);
    }
    public override int opApply (int delegate(ref Object value) dg){
        return super.opApply(dg);
    }
    public override Object[] toArray( Object[] a ){
        return super.toArray(a);
    }
    public override Object[] toArray(){
        return super.toArray();
    }
    public override String[] toArray( String[] a ){
        return super.toArray(a);
    }

    private Viewer viewer;

    /**
     * @param realm
     * @param viewer
     * @param elementType
     */
    public this(Realm realm, Viewer viewer,
            Object elementType) {
        super(realm, viewer, elementType);
        this.viewer = viewer;
    }

    public Viewer getViewer() {
        return viewer;
    }
}
